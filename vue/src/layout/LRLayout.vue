<template>
    <div class="auth-container">
        <div class="bg-image"></div>
        <div class="bg-overlay"></div>
        
        <div class="auth-content">
            <div class="auth-card">
                <div class="auth-card-content">
                    <router-view />
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'LRLayout'
}
</script>

<style scoped>
.auth-container {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    position: relative;
    overflow: hidden;
}

.bg-image {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image: url('@/assets/imgs/loginBgNew.jpg');
    background-size: cover;
    background-position: center;
    z-index: 0;
}

/* 白色蒙层：压住背景图的杂乱，把视线让给登录卡片 */
.bg-overlay {
    position: fixed;
    inset: 0;
    z-index: 0;
    background: linear-gradient(
        135deg,
        rgba(255, 255, 255, 0.26) 0%,
        rgba(255, 255, 255, 0.14) 45%,
        rgba(241, 249, 236, 0.34) 100%
    );
}

.auth-content {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 30px 24px;
    position: relative;
    z-index: 1;
    transition: all 0.8s ease;
}

/* 毛玻璃卡片 */
.auth-card {
    display: flex;
    width: 480px;
    height: auto;
    min-height: 500px;
    max-height: 90vh;
    border-radius: var(--radius-lg);
    overflow: hidden;
    position: relative;
    background: rgba(255, 255, 255, 0.72);
    -webkit-backdrop-filter: blur(24px) saturate(1.6);
    backdrop-filter: blur(24px) saturate(1.6);
    border: 1px solid rgba(255, 255, 255, 0.7);
    box-shadow:
        0 16px 48px rgba(0, 0, 0, 0.18),
        inset 0 1px 0 rgba(255, 255, 255, 0.9);
    transition: box-shadow var(--transition-base), transform var(--transition-base);
}

/* 顶部主色细条，与整站呼应 */
.auth-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 4px;
    background: linear-gradient(to right, var(--color-primary), var(--color-primary-dark));
    z-index: 2;
}

.auth-card:hover {
    transform: translateY(-2px);
    box-shadow:
        0 24px 60px rgba(0, 0, 0, 0.22),
        inset 0 1px 0 rgba(255, 255, 255, 0.9);
}

.auth-card-content {
    width: 100%;
    height: 100%;
    padding: 20px 30px;
    display: flex;
    justify-content: center;
    align-items: center;
    background: transparent;
    border-radius: inherit;
    overflow-y: auto;
}

@media (max-width: 576px) {
    .auth-content {
        padding: 24px 16px;
    }
    
    .auth-card-content {
        padding: 30px 20px;
    }
}
</style>