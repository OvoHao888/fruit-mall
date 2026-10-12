<template>
  <div class="article-detail-page">
    <front-header></front-header>
    <div class="main-content" v-loading="loading">
      <!-- 文章内容区 -->
      <div class="article-container" v-if="article">
        <h1 class="article-title">{{ article.title }}</h1>
        
        <!-- 文章摘要 -->
        <div class="article-summary" v-if="article.summary">
          <i class="el-icon-info-filled"></i>
          {{ article.summary }}
        </div>
        
        <div class="article-meta">
          <div class="meta-left">
            <span class="publish-time">
              <i class="el-icon-time"></i>
              {{ formatTime(article.createdAt) }}
            </span>
            <span class="view-count">
              <i class="el-icon-view"></i>
              {{ article.viewCount }} 阅读
            </span>
          </div>
          <div class="meta-right">
            <el-button type="text" icon="el-icon-back" @click="$router.push('/articles')">
              返回列表
            </el-button>
          </div>
        </div>

        <!-- 封面图 -->
        <div class="cover-image" v-if="article.coverImage">
          <el-image 
            :src="article.coverImage?.startsWith('http') ? article.coverImage : `/api${article.coverImage}`"
            fit="cover">
            <div slot="error" class="image-slot">
              <i class="el-icon-picture-outline"></i>
            </div>
          </el-image>
        </div>

        <!-- 文章内容 -->
        <div class="article-content" v-html="article.content"></div>
      </div>

      <!-- 空状态 -->
      <el-empty v-else-if="!loading" description="文章不存在或已被删除">
        <el-button type="primary" @click="$router.push('/articles')">返回列表</el-button>
      </el-empty>
    </div>
    <front-footer></front-footer>
  </div>
</template>

<script>
import FrontHeader from '@/components/front/FrontHeader.vue'
import FrontFooter from '@/components/front/FrontFooter.vue'
import Request from '@/utils/request'
import { formatTime } from '@/utils/time'

export default {
  name: 'ArticleDetail',
  components: {
    FrontHeader,
    FrontFooter
  },
  data() {
    return {
      loading: false,
      article: null
    }
  },
  created() {
    this.getArticleDetail()
  },
  methods: {
    formatTime,
    async getArticleDetail() {
      const id = this.$route.params.id
      if (!id) {
        this.$router.push('/articles')
        return
      }

      this.loading = true
      try {
        const res = await Request.get(`/article/${id}`)
        if (res.code === '0') {
          this.article = res.data
          // 更新浏览量
          // await Request.put(`/article/${id}/view`)
          // this.article.viewCount++
        } else {
          this.$message.error(res.msg||'获取文章详情失败')
        }
      } catch (error) {
        console.error('获取文章详情失败:', error)
        this.$message.error(error.message||'获取文章详情失败')
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.article-detail-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #f8faf5 0%, var(--bg-body) 100%);
}

.main-content {
  flex: 1;
  padding: 32px;
  max-width: 1000px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
}

.article-container {
  background: white;
  padding: 32px;
  border-radius: 12px;
  border: 1px solid var(--border-color-light);
  position: relative;
  overflow: hidden;
}

.article-container::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(to bottom, var(--color-primary), var(--color-primary-dark));
}

.article-title {
  font-size: 28px;
  font-weight: 500;
  color: var(--text-main);
  margin: 0 0 24px 0;
  line-height: 1.4;
}

.article-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 24px;
  margin-bottom: 24px;
  border-bottom: 1px solid var(--border-color-light);
  background: #f8faf5;
  padding: 16px 24px;
  border-radius: 8px;
}

.meta-left {
  display: flex;
  gap: 20px;
  color: var(--text-secondary);
  font-size: 14px;
}

.publish-time, .view-count {
  display: flex;
  align-items: center;
  gap: 4px;
}

.meta-right :deep(.el-button) {
  font-size: 14px;
}

.meta-right :deep(.el-button:hover) {
  color: var(--color-primary);
}

.cover-image {
  margin-bottom: 32px;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid var(--border-color-light);
  transition: all 0.3s ease;
}

.cover-image:hover {
  transform: scale(1.01);
}

.cover-image :deep(.el-image) {
  width: 100%;
  max-height: 400px;
}

.article-content {
  line-height: 1.8;
  color: var(--text-main);
  font-size: 16px;
  padding: 0 24px;
}

/* 取消 scoped 以便样式能作用于富文本内容 */
.article-content :deep(.w-e-text-container) {
  background: transparent;
  border: none;
}

.article-content :deep(img) {
  max-width: 100%;
  height: auto !important;
  border-radius: 4px;
  margin: 16px 0;
  display: block;
}

.article-content :deep(p) {
  margin: 16px 0;
  line-height: 1.8;
}

.article-content :deep(h1) { font-size: 28px; margin: 28px 0 18px; }
.article-content :deep(h2) { font-size: 24px; margin: 24px 0 16px; }
.article-content :deep(h3) { font-size: 20px; margin: 20px 0 14px; }
.article-content :deep(h4) { font-size: 18px; margin: 18px 0 12px; }
.article-content :deep(h5) { font-size: 16px; margin: 16px 0 10px; }
.article-content :deep(h6) { font-size: 15px; margin: 15px 0 10px; }

.article-content :deep(h1),
.article-content :deep(h2),
.article-content :deep(h3),
.article-content :deep(h4),
.article-content :deep(h5),
.article-content :deep(h6) {
  color: var(--text-main);
  font-weight: 600;
  line-height: 1.4;
}

.article-content :deep(a) {
  color: var(--color-primary);
  text-decoration: none;
  border-bottom: 1px solid transparent;
  transition: all 0.3s;
}

.article-content :deep(a:hover) {
  border-bottom-color: var(--color-primary);
}

.article-content :deep(blockquote) {
  margin: 16px 0;
  padding: 16px 24px;
  background: var(--bg-body);
  border-left: 4px solid var(--color-primary);
  color: var(--text-regular);
}

.article-content :deep(pre) {
  background: var(--bg-body);
  padding: 16px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 16px 0;
}

.article-content :deep(code) {
  background: var(--bg-body);
  padding: 2px 6px;
  border-radius: 4px;
  color: #e6a23c;
  font-family: Consolas, Monaco, 'Andale Mono', monospace;
}

.article-content :deep(ul),
.article-content :deep(ol) {
  padding-left: 24px;
  margin: 16px 0;
}

.article-content :deep(li) {
  margin: 8px 0;
  line-height: 1.6;
}

.article-content :deep(table) {
  border-collapse: collapse;
  width: 100%;
  margin: 16px 0;
}

.article-content :deep(th),
.article-content :deep(td) {
  border: 1px solid var(--border-color-light);
  padding: 12px;
  text-align: left;
}

.article-content :deep(th) {
  background-color: var(--bg-body);
  font-weight: 500;
}

.article-content :deep(hr) {
  border: none;
  border-top: 1px solid var(--border-color-light);
  margin: 24px 0;
}

/* 代码块样式优化 */
.article-content :deep(pre code) {
  background: transparent;
  padding: 0;
  color: inherit;
  display: block;
}

/* 图片说明文字样式 */
.article-content :deep(figure) {
  margin: 16px 0;
  text-align: center;
}

.article-content :deep(figcaption) {
  color: var(--text-secondary);
  font-size: 14px;
  margin-top: 8px;
}

/* 摘要样式 */
.article-summary {
  background: #f8faf5;
  padding: 16px 24px;
  border-radius: 8px;
  margin: 0 0 24px 0;
  color: var(--text-regular);
  font-size: 15px;
  line-height: 1.6;
  display: flex;
  align-items: flex-start;
  gap: 12px;
  position: relative;
  overflow: hidden;
}

.article-summary::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(103, 194, 58, 0.05), transparent);
}

.article-summary i {
  color: var(--color-primary);
  font-size: 18px;
  margin-top: 3px;
}
</style> 