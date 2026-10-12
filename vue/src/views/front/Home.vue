<template>
  <div class="home" v-if="refresh" :key="refresh">
    <front-header></front-header>
    <div class="main-content">
      <!-- 加载动画 -->
      <div class="loading-container" v-if="loading">
        <div class="loading-spinner">
          <i class="el-icon-loading"></i>
        </div>
        <div class="loading-text">加载中...</div>
      </div>

      <!-- 轮播图和公告区域 -->
      <div v-else>
        <div class="carousel-notice-section">
          <div class="carousel-wrapper">
            <front-carousel></front-carousel>
          </div>
          <div class="notice-wrapper">
            <front-notice></front-notice>
          </div>
        </div>

        <!-- AI 智能导购区域 -->
        <div class="section ai-section">
          <div class="section-header">
            <div class="title-wrapper">
              <div class="title-icon-wrapper ai-icon">
                <i class="el-icon-cpu"></i>
              </div>
              <div class="title-content">
                <h2 class="section-title">
                  <span>AI 智能导购</span>
                </h2>
                <div class="subtitle">告诉 AI 您想要什么，为您精准推荐</div>
              </div>
            </div>
          </div>
          
          <div class="ai-input-wrapper">
            <el-input 
              v-model="aiRequirement" 
              placeholder="例如：推荐一些适合做火锅的食材，或者周末聚会吃的水果" 
              class="ai-input"
              @keyup.enter.native="handleAiRecommend"
            >
              <el-button slot="append" icon="el-icon-magic-stick" @click="handleAiRecommend" :loading="aiLoading">智能推荐</el-button>
            </el-input>
          </div>

          <div class="product-grid" v-if="aiProducts.length > 0">
            <div class="product-item" v-for="product in aiProducts" :key="product.id">
              <product-card :product="product" @add-to-cart="handleAddToCart" @toggle-favorite="handleToggleFavorite"></product-card>
            </div>
          </div>
          <div v-else-if="aiSearched && !aiLoading" class="no-result">
            <i class="el-icon-warning-outline"></i>
            <span>暂无相关推荐，换个说法试试？</span>
          </div>
        </div>
        
        <front-category></front-category>

        <!-- 推荐商品区域 -->
        <div class="section recommend-section">
          <div class="section-header">
            <div class="title-wrapper">
              <div class="title-icon-wrapper">
                <i class="el-icon-star-on"></i>
              </div>
              <div class="title-content">
                <h2 class="section-title">
                  <span>为您推荐</span>
                </h2>
                <div class="subtitle">精选优质好物，专属于您的推荐</div>
              </div>
            </div>
            <div class="more-btn" @click="$router.push('/products')">
              <span>查看更多</span>
              <i class="el-icon-arrow-right"></i>
            </div>
          </div>
          
          <div class="product-grid">
            <div class="product-item" v-for="product in recommendProducts" :key="product.id">
              <product-card :product="product" @add-to-cart="handleAddToCart" @toggle-favorite="handleToggleFavorite"></product-card>
            </div>
          </div>
        </div>

        <!-- 新品上市区域 -->
        <div class="section new-products-section">
          <div class="section-header">
            <div class="title-wrapper">
              <div class="title-icon-wrapper new-icon">
                <i class="el-icon-goods"></i>
              </div>
              <div class="title-content">
                <h2 class="section-title">
                  <span>好物优选</span>
                </h2>
                <div class="subtitle">甄选好物优品，新鲜送达您家</div>
              </div>
            </div>
            <div class="more-btn" @click="$router.push('/products?type=new')">
              <span>查看更多</span>
              <i class="el-icon-arrow-right"></i>
            </div>
          </div>
          
          <div class="product-grid">
            <div class="product-item" v-for="product in newProducts" :key="product.id">
              <product-card :product="product" @add-to-cart="handleAddToCart" @toggle-favorite="handleToggleFavorite"></product-card>
            </div>
          </div>
        </div>
      </div>
    </div>
    <front-footer></front-footer>
  </div>
</template>

<script>
import FrontHeader from '@/components/front/FrontHeader.vue'
import FrontFooter from '@/components/front/FrontFooter.vue'
import FrontCarousel from '@/components/front/FrontCarousel.vue'
import FrontCategory from '@/components/front/FrontCategory.vue'
import ProductCard from '@/components/front/ProductCard.vue'
import FrontNotice from '@/components/front/FrontNotice.vue'
import Request from '@/utils/request'

export default {
  name: 'Home',
  components: {
    FrontHeader,
    FrontFooter,
    FrontCarousel,
    FrontCategory,
    ProductCard,
    FrontNotice
  },
  data() {
    return {
      recommendProducts: [],
      newProducts: [],
      isLoggedIn: false,
      refresh: true,
      loading: true,
      // AI 推荐相关数据
      aiRequirement: '',
      aiProducts: [],
      aiLoading: false,
      aiSearched: false
    }
  },
  computed: {
   
  },
  methods: {
    // 修改 checkLoginStatus 方法
    checkLoginStatus() {
      const token = localStorage.getItem('token');
      const userStr = localStorage.getItem('frontUser');
      
      if (token && userStr) {
        try {
          const user = JSON.parse(userStr);
       
          // 检查用户角色，如果不是 USER 则注销
          if (user.role !== 'USER') {
            this.logout();
            this.$message.warning('请使用普通用户账号访问');
            return;
          }
          this.isLoggedIn = true;
        } catch (error) {
          this.logout();
        }
      } else {
        this.isLoggedIn = false;
      }
    },

    // 修改 logout 方法
    logout() {
      localStorage.removeItem('token');
      localStorage.removeItem('frontUser');
      this.isLoggedIn = false;
      // 强制刷新整个页面
      window.location.reload()
   
    },

    // 获取推荐商品
    async getRecommendProducts() {
      try {
        this.loading = true; // 开始加载
        // 重新检查登录状态
        this.checkLoginStatus();
        
        let products = [];
        
        if (!this.isLoggedIn) {
          // 未登录状态 - 获取随机排序的前8条商品
          const res = await Request.get('/product/page?status=1&size=8');
          if (res.code === '0') {
            products = res.data.records || res.data;
            // 随机排序
            products = products.sort(() => Math.random() - 0.5);
          }
        } else {
          // 登录状态 - 获取个性化推荐
          const userStr = localStorage.getItem('frontUser');
          if (!userStr) {
            throw new Error('User info not found');
          }
          const userId = JSON.parse(userStr).id;
          const res = await Request.get(`/recommend/user/${userId}`);
          if (res.code === '0') {
            products = res.data.records || res.data;
          }
          
          // 获取收藏状态
          try {
            const favRes = await Request.get(`/favorite/user/${userId}`);
            if (favRes.code === '0') {
              const favorites = favRes.data;
              products = products.map(product => ({
                ...product,
                isFavorite: favorites.some(f => f.productId === product.id && f.status === 1)
              }));
            }
          } catch (error) {
            console.error('获取收藏状态失败:', error);
            products = products.map(product => ({
              ...product,
              isFavorite: false
            }));
          }
        }

        // 设置推荐商品
        this.recommendProducts = products.map(product => ({
          ...product,
          isFavorite: product.isFavorite || false
        }));

      } catch (error) {
        console.error('获取推荐商品失败:', error);
        // 如果获取失败，回退到未登录状态的推荐
        this.isLoggedIn = false;
        this.getRecommendProducts();
      } finally {
        // 结束加载
        setTimeout(() => {
          this.loading = false;
        }, 500);
      }
    },
    // 获取新品
    async getNewProducts() {
      try {
        const res = await Request.get('/product/page?status=1&sort=updatedAt,desc&size=4')
        if (res.code === '0') {
          this.newProducts = res.data.records.map(product => ({
            ...product,
            isFavorite: false
          }))
        }
      } catch (error) {
        console.error('获取新品失败:', error)
      }
    },
    // 添加到购物车
    handleAddToCart(product) {
      this.$message({
        type: 'success',
        message: '已添加到购物车'
      })
    },
    // 切换收藏状态
    async handleToggleFavorite({ product, status }) {
      // 更新本地数据
      const targetProduct = this.recommendProducts.find(p => p.id === product.id)
      if (targetProduct) {
        targetProduct.isFavorite = status === 1
      }
      
      // 同时更新新品列表中的收藏状态
      const newProduct = this.newProducts.find(p => p.id === product.id)
      if (newProduct) {
        newProduct.isFavorite = status === 1
      }

      // 更新 AI 推荐列表中的收藏状态
      const aiProduct = this.aiProducts.find(p => p.id === product.id)
      if (aiProduct) {
        aiProduct.isFavorite = status === 1
      }
    },
    // AI 推荐
    async handleAiRecommend() {
      if (!this.aiRequirement.trim()) {
        this.$message.warning('请输入您的需求')
        return
      }
      
      this.aiLoading = true
      this.aiSearched = true
      this.aiProducts = []
      
      try {
        const res = await Request.post('/ai/recommend', {
          requirement: this.aiRequirement
        })
        
        if (res.code === '0') {
          this.aiProducts = res.data.map(product => ({
            ...product,
            isFavorite: false // 默认为未收藏，实际项目中可以进一步查询收藏状态
          }))
          
          if (this.aiProducts.length === 0) {
            this.$message.info('AI 没有找到匹配的商品，请尝试其他描述')
          } else {
            this.$message.success('AI 为您推荐了 ' + this.aiProducts.length + ' 款商品')
          }
        } else {
          this.$message.error(res.msg || 'AI 推荐失败')
        }
      } catch (error) {
        console.error('AI 推荐出错:', error)
        this.$message.error('AI 服务暂时不可用')
      } finally {
        this.aiLoading = false
      }
    }
  },
  created() {
    // 添加登录状态检查
    this.checkLoginStatus();
    this.getRecommendProducts();
    this.getNewProducts();
  },
  mounted() {
    const userStr = localStorage.getItem('frontUser');
    if (userStr) {
      this.isLoggedIn = true;
    }
  }
}
</script>

<style scoped>
.home {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(to bottom, #fff, #f8faf5);
}
.main-content {
  flex: 1;
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
}
.section {
  margin: 32px 0;
  position: relative;
}

.recommend-section {
  padding: 30px 20px;
  background: linear-gradient(to bottom right, #f8faf5, #ffffff);
  border-radius: 20px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.04);
  position: relative;
  overflow: hidden;
}

.recommend-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 6px;
  background: linear-gradient(to right, var(--color-accent), #ffb74d);
  border-radius: 3px 3px 0 0;
}

.recommend-section::after {
  content: '';
  position: absolute;
  inset: 0;
  background-image:
    radial-gradient(circle at 10% 10%, rgba(255, 125, 0, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 90% 90%, rgba(255, 125, 0, 0.05) 0%, transparent 50%);
  z-index: 0;
}

.section::before {
  content: '';
  position: absolute;
  inset: -16px;
  background: 
    radial-gradient(circle at 0% 0%, rgba(255, 183, 0, 0.03) 0%, transparent 50%),
    radial-gradient(circle at 100% 100%, rgba(255, 183, 0, 0.03) 0%, transparent 50%);
  z-index: -1;
  border-radius: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  position: relative;
  z-index: 1;
}

.title-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  gap: 16px;
}

.title-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-accent), #ffb74d);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(255, 125, 0, 0.2);
}

.title-icon-wrapper i {
  color: white;
  font-size: 24px;
}

.title-content {
  display: flex;
  flex-direction: column;
}

.section-title {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #333;
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-title i {
  color: var(--color-secondary);
  font-size: 22px;
}

.title-line {
  position: absolute;
  bottom: -4px;
  left: 0;
  width: 100%;
  height: 8px;
  background: rgba(255, 183, 0, 0.2);
  border-radius: 4px;
  z-index: 0;
}

.subtitle {
  font-size: 14px;
  color: var(--text-secondary);
  margin-top: 4px;
}

.more-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 20px;
  background: linear-gradient(135deg,
    rgba(255, 125, 0, 0.1),
    rgba(255, 125, 0, 0.15)
  );
  color: var(--color-accent);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.more-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg,
    rgba(255, 125, 0, 0.15),
    rgba(255, 125, 0, 0.2)
  );
  opacity: 0;
  transition: opacity 0.3s ease;
}

.more-btn:hover {
  transform: translateX(4px);
}

.more-btn:hover::before {
  opacity: 1;
}

.more-btn i {
  font-size: 14px;
  transition: transform 0.3s ease;
  position: relative;
  z-index: 1;
}

.more-btn span {
  position: relative;
  z-index: 1;
}

.more-btn:hover i {
  transform: translateX(2px);
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  position: relative;
  z-index: 1;
}

.product-item {
  animation: fadeIn 0.6s ease forwards;
  opacity: 0;
}

.product-item:nth-child(1) { animation-delay: 0.1s; }
.product-item:nth-child(2) { animation-delay: 0.2s; }
.product-item:nth-child(3) { animation-delay: 0.3s; }
.product-item:nth-child(4) { animation-delay: 0.4s; }
.product-item:nth-child(5) { animation-delay: 0.5s; }
.product-item:nth-child(6) { animation-delay: 0.6s; }
.product-item:nth-child(7) { animation-delay: 0.7s; }
.product-item:nth-child(8) { animation-delay: 0.8s; }

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 1200px) {
  .main-content {
    padding: 16px;
  }
  
  .section-title {
    font-size: 20px;
  }
  
  .section-title i {
    font-size: 20px;
  }
  
  .product-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .section {
    margin: 24px 0;
  }
  
  .recommend-section {
    padding: 24px 16px;
  }
  
  .section-title {
    font-size: 18px;
  }
  
  .title-icon-wrapper {
    width: 40px;
    height: 40px;
  }
  
  .title-icon-wrapper i {
    font-size: 20px;
  }
  
  .title-wrapper {
    gap: 12px;
  }
  
  .subtitle {
    font-size: 13px;
  }
  
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }
}

@media (max-width: 480px) {
  .product-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .title-content {
    max-width: 160px;
  }
}

.carousel-notice-section {
  display: flex;
  gap: 24px;
  margin: 20px 0 40px;
  height: 380px;
}

.carousel-wrapper {
  flex: 3;
  min-width: 0;
  height: 100%;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.notice-wrapper {
  flex: 1;
  min-width: 320px;
  max-width: 380px;
  height: 100%;
}

@media (max-width: 1200px) {
  .carousel-notice-section {
    flex-direction: column;
    gap: 20px;
    height: auto;
    margin-bottom: 30px;
  }
  
  .carousel-wrapper {
    height: 320px;
  }
  
  .notice-wrapper {
    max-width: none;
    height: 320px;
  }
}

@media (max-width: 768px) {
  .carousel-notice-section {
    gap: 16px;
    margin-bottom: 24px;
  }
  
  .carousel-wrapper {
    height: 240px;
  }
  
  .notice-wrapper {
    height: 280px;
  }
}

/* 加载动画样式 */
.loading-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 500px;
}

.loading-spinner {
  font-size: 48px;
  color: var(--color-primary);
  animation: pulse 1.5s infinite;
}

.loading-text {
  margin-top: 16px;
  font-size: 16px;
  color: var(--text-secondary);
  font-weight: 500;
}

@keyframes pulse {
  0% {
    opacity: 0.6;
    transform: scale(0.95);
  }
  50% {
    opacity: 1;
    transform: scale(1.05);
  }
  100% {
    opacity: 0.6;
    transform: scale(0.95);
  }
}

.ai-section {
  padding: 30px 20px;
  background: linear-gradient(135deg, #f1f9ec, #e8f5df);
  border-radius: var(--radius-lg);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.04);
  position: relative;
  overflow: hidden;
  margin-bottom: 40px;
}

.ai-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 6px;
  background: linear-gradient(to right, var(--color-primary), var(--color-primary-dark));
  border-radius: 3px 3px 0 0;
}

.ai-icon {
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-dark));
  box-shadow: 0 4px 12px rgba(103, 194, 58, 0.2);
}

.ai-input-wrapper {
  max-width: 800px;
  margin: 0 auto 30px;
  position: relative;
  z-index: 1;
}

.ai-input :deep(.el-input__inner) {
  height: 50px;
  line-height: 50px;
  border-radius: 25px 0 0 25px;
  border: 2px solid var(--color-primary-light);
  border-right: none;
  font-size: 16px;
  padding-left: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
  transition: all 0.3s;
}

.ai-input :deep(.el-input__inner:focus) {
  border-color: var(--color-primary);
  box-shadow: 0 4px 16px rgba(103, 194, 58, 0.15);
}

.ai-input :deep(.el-input-group__append) {
  border-radius: 0 25px 25px 0;
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-dark));
  border: none;
  color: white;
  font-size: 16px;
  padding: 0 30px;
  box-shadow: 0 4px 12px rgba(103, 194, 58, 0.25);
}

.ai-input :deep(.el-button) {
  border: none;
  color: white;
  font-weight: 500;
}

.ai-input :deep(.el-button:hover) {
  background: transparent;
  opacity: 0.9;
}

.no-result {
  text-align: center;
  padding: 40px 0;
  color: var(--text-secondary);
  font-size: 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.no-result i {
  font-size: 32px;
  color: #d9d9d9;
}

@media (max-width: 768px) {
  .ai-section {
    padding: 24px 16px;
  }
  
  .ai-input :deep(.el-input__inner) {
    height: 44px;
    line-height: 44px;
    font-size: 14px;
  }
  
  .ai-input :deep(.el-input-group__append) {
    padding: 0 20px;
    font-size: 14px;
  }
}

.new-products-section {
  padding: 30px 20px;
  background: linear-gradient(to bottom left, #ffffff, #f8faf5);
  border-radius: 20px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.04);
  position: relative;
  overflow: hidden;
  margin-top: 40px;
}

.new-products-section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 6px;
  background: linear-gradient(to right, var(--color-primary), var(--color-primary-dark));
  border-radius: 3px 3px 0 0;
}

.new-products-section::after {
  content: '';
  position: absolute;
  inset: 0;
  background-image:
    radial-gradient(circle at 90% 10%, rgba(103, 194, 58, 0.05) 0%, transparent 50%),
    radial-gradient(circle at 10% 90%, rgba(103, 194, 58, 0.05) 0%, transparent 50%);
  z-index: 0;
}

.new-icon {
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-dark));
  box-shadow: 0 4px 12px rgba(103, 194, 58, 0.2);
}

@media (max-width: 768px) {
  .new-products-section {
    padding: 24px 16px;
    margin-top: 30px;
  }
}
</style> 