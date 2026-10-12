<template>
  <div class="customer-chat">
    <div class="page-header">
      <h2>顾客咨询</h2>
      <el-tag type="info">共 {{ conversations.length }} 个会话</el-tag>
    </div>

    <div class="chat-container">
      <div class="conversation-list">
        <div class="list-header">
          <el-input 
            v-model="searchKey" 
            placeholder="搜索顾客..." 
            prefix-icon="el-icon-search"
            size="small"
            clearable
          />
        </div>
        <div class="list-content">
          <div 
            v-for="conv in filteredConversations" 
            :key="conv.product_id + '-' + conv.customer_id"
            class="conversation-item"
            :class="{ active: currentConversation && currentConversation.product_id === conv.product_id && currentConversation.customer_id === conv.customer_id }"
            @click="selectConversation(conv)"
          >
            <div class="customer-info">
              <el-avatar :size="40" class="avatar">
                {{ (conv.customer_username || conv.customer_name || '顾').charAt(0).toUpperCase() }}
              </el-avatar>
              <div class="info-text">
                <div class="customer-name">{{ conv.customer_name || conv.customer_username || '顾客' }}</div>
                <div class="product-name">{{ conv.product_name }}</div>
              </div>
            </div>
            <div class="conversation-meta">
              <div class="last-time" v-if="conv.last_message_time">{{ formatTime(conv.last_message_time) }}</div>
              <el-badge :value="conv.unread_count" :hidden="!conv.unread_count" class="unread-badge" />
            </div>
          </div>
          <el-empty v-if="conversations.length === 0" description="暂无咨询消息" />
        </div>
      </div>

      <div class="chat-area">
        <template v-if="currentConversation">
          <div class="chat-header">
            <div class="header-info">
              <span class="customer-name">{{ currentConversation.customer_name || currentConversation.customer_username }}</span>
              <span class="product-info">咨询商品: {{ currentConversation.product_name }}</span>
            </div>
          </div>
          
          <div class="chat-messages" ref="messagesContainer">
            <div 
              v-for="(msg, index) in chatMessages" 
              :key="index" 
            >
              <div v-if="shouldShowTime(index)" class="time-divider">
                <span>{{ formatChatTime(msg.created_at) }}</span>
              </div>
              <div 
                :class="['message-item', msg.sender_id === userInfo.id ? 'sent' : 'received']"
              >
                <div v-if="msg.sender_id !== userInfo.id" class="message-avatar">
                  <i class="el-icon-user-solid"></i>
                </div>
                <div class="message-bubble">
                  <div class="message-text">{{ msg.content }}</div>
                </div>
                <div v-if="msg.sender_id === userInfo.id" class="message-avatar sent-avatar">
                  <i class="el-icon-user-solid"></i>
                </div>
              </div>
            </div>
            <div v-if="chatMessages.length === 0" class="no-messages">
              <i class="el-icon-chat-line-round"></i>
              <p>暂无聊天记录</p>
            </div>
          </div>

          <div class="chat-input-area">
            <el-input 
              v-model="chatInput" 
              placeholder="输入消息..." 
              @keyup.enter.native="sendMessage"
              class="chat-input"
            />
            <el-button type="primary" @click="sendMessage" :disabled="!chatInput.trim()">
              发送
            </el-button>
          </div>
        </template>
        <div v-else class="no-conversation">
          <i class="el-icon-chat-dot-round"></i>
          <p>选择一个会话开始聊天</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Request from '@/utils/request'

export default {
  name: 'CustomerChat',
  inject: ['userInfo'],
  data() {
    return {
      conversations: [],
      currentConversation: null,
      chatMessages: [],
      chatInput: '',
      searchKey: '',
      refreshTimer: null
    }
  },
  computed: {
    filteredConversations() {
      if (!this.searchKey) return this.conversations
      const key = this.searchKey.toLowerCase()
      return this.conversations.filter(conv => 
        (conv.customer_name && conv.customer_name.toLowerCase().includes(key)) ||
        (conv.customer_username && conv.customer_username.toLowerCase().includes(key)) ||
        (conv.product_name && conv.product_name.toLowerCase().includes(key))
      )
    }
  },
  created() {
    this.loadConversations()
    this.startAutoRefresh()
  },
  beforeDestroy() {
    this.stopAutoRefresh()
  },
  methods: {
    async loadConversations() {
      try {
        const res = await Request.get('/chat/merchant/conversations', {
          params: { merchantId: this.userInfo.id }
        })
        if (res.code === '0') {
          this.conversations = res.data || []
          if (this.currentConversation) {
            await this.loadChatMessages()
          }
        }
      } catch (error) {
        console.error('加载会话列表失败:', error)
      }
    },
    async selectConversation(conv) {
      this.currentConversation = conv
      await this.loadChatMessages()
      if (conv.unread_count > 0) {
        await Request.put('/chat/read', null, {
          params: {
            productId: conv.product_id,
            customerId: conv.customer_id,
            merchantId: this.userInfo.id
          }
        })
        conv.unread_count = 0
      }
    },
    async loadChatMessages() {
      if (!this.currentConversation) return
      
      try {
        const res = await Request.get('/chat/conversation', {
          params: {
            productId: this.currentConversation.product_id,
            customerId: this.currentConversation.customer_id
          }
        })
        if (res.code === '0') {
          this.chatMessages = res.data || []
          this.$nextTick(() => {
            this.scrollToBottom()
          })
        }
      } catch (error) {
        console.error('加载聊天记录失败:', error)
      }
    },
    async sendMessage() {
      if (!this.chatInput.trim() || !this.currentConversation) return
      
      try {
        const messageData = {
          productId: this.currentConversation.product_id,
          customerId: this.currentConversation.customer_id,
          merchantId: this.userInfo.id,
          senderId: this.userInfo.id,
          content: this.chatInput.trim(),
          type: 1
        }
        
        const res = await Request.post('/chat', messageData)
        if (res.code === '0') {
          this.chatInput = ''
          await this.loadChatMessages()
          await this.loadConversations()
        }
      } catch (error) {
        console.error('发送消息失败:', error)
        this.$message.error('发送失败')
      }
    },
    scrollToBottom() {
      const container = this.$refs.messagesContainer
      if (container) {
        container.scrollTop = container.scrollHeight
      }
    },
    formatTime(timestamp) {
      if (!timestamp) return ''
      const date = new Date(timestamp)
      const now = new Date()
      const diff = now - date
      
      if (diff < 60000) return '刚刚'
      if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
      if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
      if (diff < 604800000) return Math.floor(diff / 86400000) + '天前'
      
      return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit' })
    },
    formatChatTime(timestamp) {
      if (!timestamp) return ''
      const date = new Date(timestamp)
      const now = new Date()
      const isToday = date.toDateString() === now.toDateString()
      
      if (isToday) {
        return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
      } else {
        return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
      }
    },
    shouldShowTime(index) {
      if (index === 0) return true
      const currentMsg = this.chatMessages[index]
      const prevMsg = this.chatMessages[index - 1]
      if (!currentMsg || !prevMsg || !currentMsg.created_at || !prevMsg.created_at) return true
      
      const currentTime = new Date(currentMsg.created_at).getTime()
      const prevTime = new Date(prevMsg.created_at).getTime()
      const fiveMinutes = 5 * 60 * 1000
      
      return (currentTime - prevTime) > fiveMinutes
    },
    startAutoRefresh() {
      this.refreshTimer = setInterval(() => {
        this.loadConversations()
      }, 5000)
    },
    stopAutoRefresh() {
      if (this.refreshTimer) {
        clearInterval(this.refreshTimer)
        this.refreshTimer = null
      }
    }
  }
}
</script>

<style scoped>
.customer-chat {
  height: 100%;
  display: flex;
  flex-direction: column;
  background: var(--bg-body);
}

.page-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
  padding: 0 4px;
}

.page-header h2 {
  font-size: 20px;
  font-weight: 600;
  color: var(--text-main);
  margin: 0;
  margin-right: 12px;
}

.chat-container {
  flex: 1;
  display: flex;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.conversation-list {
  width: 320px;
  border-right: 1px solid var(--border-color-light);
  display: flex;
  flex-direction: column;
}

.list-header {
  padding: 16px;
  border-bottom: 1px solid var(--border-color-light);
}

.list-content {
  flex: 1;
  overflow-y: auto;
}

.conversation-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.3s;
  border-bottom: 1px solid var(--bg-body);
}

.conversation-item:hover {
  background: var(--bg-body);
}

.conversation-item.active {
  background: #ecf5ff;
}

.customer-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
}

.avatar {
  background: linear-gradient(135deg, var(--color-primary), #66b1ff);
  color: white;
  flex-shrink: 0;
}

.info-text {
  min-width: 0;
}

.customer-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-main);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.product-name {
  font-size: 12px;
  color: var(--text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.conversation-meta {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 4px;
}

.last-time {
  font-size: 11px;
  color: #c0c4cc;
}

.unread-badge :deep(.el-badge__content) {
  transform: scale(0.9);
}

.chat-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.chat-header {
  padding: 16px 20px;
  border-bottom: 1px solid var(--border-color-light);
  background: #fafafa;
}

.header-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.header-info .customer-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--text-main);
}

.product-info {
  font-size: 13px;
  color: var(--text-secondary);
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: var(--bg-body);
}

.time-divider {
  text-align: center;
  margin: 16px 0;
}

.time-divider span {
  background: #e0e0e0;
  color: #666;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
}

.message-item {
  margin-bottom: 16px;
  display: flex;
  align-items: flex-start;
}

.message-item.sent {
  justify-content: flex-end;
}

.message-item.received {
  justify-content: flex-start;
}

.message-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-dark));
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 18px;
  flex-shrink: 0;
}

.message-avatar.sent-avatar {
  background: linear-gradient(135deg, var(--color-primary), #66b1ff);
}

.message-bubble {
  max-width: 60%;
  padding: 12px 16px;
  border-radius: 16px;
  position: relative;
  margin: 0 10px;
}

.message-item.sent .message-bubble {
  background: linear-gradient(135deg, var(--color-primary), #66b1ff);
  color: white;
  border-bottom-right-radius: 4px;
}

.message-item.received .message-bubble {
  background: white;
  color: var(--text-main);
  border-bottom-left-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.message-sender {
  font-size: 12px;
  margin-bottom: 4px;
  opacity: 0.8;
}

.message-text {
  font-size: 14px;
  line-height: 1.5;
  word-break: break-word;
}

.message-time {
  font-size: 11px;
  margin-top: 4px;
  opacity: 0.7;
  text-align: right;
}

.no-messages {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: var(--text-secondary);
}

.no-messages i {
  font-size: 48px;
  margin-bottom: 16px;
}

.no-messages p {
  margin: 0;
  font-size: 14px;
}

.chat-input-area {
  display: flex;
  gap: 12px;
  padding: 16px;
  border-top: 1px solid var(--border-color-light);
  background: white;
}

.chat-input {
  flex: 1;
}

.chat-input :deep(.el-input__inner) {
  border-radius: 20px;
}

.no-conversation {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #c0c4cc;
}

.no-conversation i {
  font-size: 64px;
  margin-bottom: 16px;
}

.no-conversation p {
  font-size: 16px;
}
</style>
