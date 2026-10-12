<template>
  <div class="header-bar">
    <div class="header-left">
      <BreadCrumbs />
    </div>
    <div class="header-right">
      <div class="current-time">
        <i class="el-icon-time"></i>
        <span>{{ currentTime }}</span>
      </div>
      <div class="header-actions">
        <el-tooltip content="通知提醒" placement="bottom" v-if="isMerchant">
          <div class="action-btn notification-btn" @click="handleNotification">
            <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99" class="notification-badge">
              <i class="el-icon-bell"></i>
            </el-badge>
            <span>通知</span>
          </div>
        </el-tooltip>
        
        <div class="action-group">
          <el-tooltip content="刷新页面" placement="bottom">
            <div class="action-icon-btn" @click="refreshPage">
              <i class="el-icon-refresh-right"></i>
            </div>
          </el-tooltip>
          
          <el-tooltip :content="isFullscreen ? '退出全屏' : '全屏显示'" placement="bottom">
            <div class="action-icon-btn" @click="toggleFullScreen">
              <i :class="isFullscreen ? 'el-icon-close' : 'el-icon-full-screen'"></i>
            </div>
          </el-tooltip>
        </div>

        <div class="divider"></div>
        <UserAvatar />
      </div>
    </div>
  </div>
</template>

<script>
import BreadCrumbs from '../components/BreadCrumbs/index.vue'
import UserAvatar from '../components/UserAvatar/index.vue'
import Request from '@/utils/request'

export default {
  name: 'HeaderBar',
  components: {
    BreadCrumbs,
    UserAvatar
  },
  inject: ['userInfo'],
  data() {
    return {
      isFullscreen: false,
      currentTime: '',
      timer: null,
      unreadCount: 0,
      refreshTimer: null
    }
  },
  computed: {
    isMerchant() {
      return this.userInfo && this.userInfo.role === 'MERCHANT'
    }
  },
  methods: {
    refreshPage() {
      window.location.reload()
    },
    toggleFullScreen() {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen()
        this.isFullscreen = true
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen()
          this.isFullscreen = false
        }
      }
    },
    updateTime() {
      const now = new Date();
      const options = { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric', 
        weekday: 'long',
        hour: '2-digit', 
        minute: '2-digit', 
        second: '2-digit' 
      };
      this.currentTime = now.toLocaleDateString('zh-CN', options).replace(/\//g, '-');
    },
    async loadUnreadCount() {
      if (!this.userInfo) return
      
      try {
        const res = await Request.get('/chat/notification', {
          params: { merchantId: this.userInfo.id }
        })
        if (res.code === '0') {
          this.unreadCount = res.data.totalUnread || 0
        }
      } catch (error) {
        console.error('获取未读消息数失败:', error)
      }
    },
    async handleNotification() {
      if (this.unreadCount > 0) {
        try {
          const res = await Request.get('/chat/merchant/conversations', {
            params: { merchantId: this.userInfo.id }
          })
          if (res.code === '0' && res.data && res.data.length > 0) {
            const latestConv = res.data.find(c => c.unread_count > 0) || res.data[0]
            this.$router.push('/customerChat')
          }
        } catch (error) {
          console.error('获取会话列表失败:', error)
        }
      } else {
        this.$router.push('/customerChat')
      }
    },
    startAutoRefresh() {
      if (!this.isMerchant) return
      this.loadUnreadCount()
      this.refreshTimer = setInterval(() => {
        this.loadUnreadCount()
      }, 10000)
    },
    stopAutoRefresh() {
      if (this.refreshTimer) {
        clearInterval(this.refreshTimer)
        this.refreshTimer = null
      }
    }
  },
  mounted() {
    document.addEventListener('fullscreenchange', () => {
      this.isFullscreen = !!document.fullscreenElement
    })
    this.updateTime();
    this.timer = setInterval(this.updateTime, 1000);
    this.startAutoRefresh()
  },
  beforeDestroy() {
    if (this.timer) {
      clearInterval(this.timer);
    }
    this.stopAutoRefresh()
  }
}
</script>

<style lang="less" scoped>
.header-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
  padding: 0;
  background: #ffffff;
  border-bottom: none;
  width: 100%;
  box-sizing: border-box;
  min-height: 64px;
  
  .header-left {
    display: flex;
    align-items: center;
    height: 100%;
  }
  
  .header-right {
    display: flex;
    align-items: center;
    gap: 16px;
    height: 100%;
    
    .current-time {
      display: flex;
      align-items: center;
      gap: 8px;
      color: var(--text-regular);
      font-size: 14px;
      background: var(--bg-body);
      padding: 6px 12px;
      border-radius: 20px;
      white-space: nowrap;
      
      i {
        color: var(--color-primary);
        font-size: 16px;
      }
    }
    
    .header-actions {
      display: flex;
      align-items: center;
      gap: 12px;
      
      .action-btn {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border-radius: 20px;
        cursor: pointer;
        transition: all 0.3s ease;
        background: var(--color-primary);
        color: white;
        font-size: 14px;
        box-shadow: 0 2px 6px rgba(103, 194, 58, 0.2);
        
        &:hover {
          transform: translateY(-1px);
          box-shadow: 0 4px 12px rgba(103, 194, 58, 0.3);
        }
        
        i {
          font-size: 16px;
        }
      }

      .notification-btn {
        background: linear-gradient(135deg, var(--color-primary), var(--color-primary-dark));
        position: relative;
        
        &:hover {
          box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
        }
      }

      .notification-badge {
        line-height: 1;
      }

      .notification-badge :deep(.el-badge__content) {
        transform: scale(0.9);
        top: -4px;
        right: calc(-10px + 6px / 2);
      }

      .action-group {
        display: flex;
        align-items: center;
        gap: 8px;
        background: var(--bg-body);
        padding: 4px;
        border-radius: 16px;
      }
      
      .action-icon-btn {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        cursor: pointer;
        transition: all 0.3s ease;
        color: var(--text-regular);
        
        i {
          font-size: 18px;
          transition: all 0.3s ease;
        }
        
        &:hover {
          background-color: white;
          color: var(--color-primary);
          box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
          
          i.el-icon-refresh-right {
            transform: rotate(180deg);
          }
        }
      }
      
      .divider {
        width: 1px;
        height: 24px;
        background: #e4e7ed;
        margin: 0 8px;
      }
    }
  }
}

:deep(.el-badge__content.is-fixed) {
  top: 8px;
  right: 8px;
  border: 2px solid white;
}

:deep(.el-badge__content) {
  background-color: var(--color-danger);
  box-shadow: 0 2px 4px rgba(245, 108, 108, 0.2);
}

:deep(.el-tooltip__popper) {
  font-size: 13px;
}

@media (max-width: 992px) {
  .current-time span {
    display: none;
  }
  
  .current-time {
    padding: 6px !important;
  }
}
</style>
