# 果蔬商城 Design Tokens

> 单一事实来源：`src/assets/css/theme.css`。本文件为对照说明，两者必须保持一致。

## 色彩系统 (Color System)

### 主色调 (Primary Palette) —— 生鲜绿
用于品牌标识、导航、关键行动点、链接、选中态。
- **Primary Base**: `#67C23A` (`var(--color-primary)`) - 新鲜、健康、可信赖
- **Primary Light**: `#e1f3d8` (`var(--color-primary-light)`) - 背景、选中态
- **Primary Dark**: `#529b2e` (`var(--color-primary-dark)`) - Hover、点击态

### 辅助色 (Secondary / Accent Palette) —— 活力橙
用于促销角标、价格、强调信息。
- **Accent Base**: `#FF7D00` (`var(--color-accent)` / `var(--color-secondary)`) - 温暖、活力、食欲
- **Accent Light**: `#fff3e6` (`var(--color-accent-light)`)
- **Accent Dark**: `#e66f00` (`var(--color-accent-dark)`)
- **价格专用**: `var(--color-price)` = `#FF7D00`，价格一律走此变量

### 功能色 (Functional Colors)
- **Success**: `#67C23A` (`var(--color-success)`) - 与主色同值
- **Warning**: `#faad14` (`var(--color-warning)`)
- **Danger**: `#f56c6c` (`var(--color-danger)`) - 全站唯一红色，不要再引入新红
- **Info**: `#909399` (`var(--color-info)`)

### 文字颜色 (Typography Colors)
- **Main Text**: `#303133` (`var(--text-main)`)
- **Regular Text**: `#606266` (`var(--text-regular)`)
- **Secondary Text**: `#909399` (`var(--text-secondary)`)
- **Placeholder**: `#c0c4cc` (`var(--text-placeholder)`)

### 背景与边框 (Background & Border)
- **Body Background**: `#f7f8fa` (`var(--bg-body)`)
- **Card Background**: `#ffffff` (`var(--bg-white)`)
- **Base Border**: `#dcdfe6` (`var(--border-color-base)`)
- **Light Border**: `#ebeef5` (`var(--border-color-light)`)

## 圆角 (Radius) —— 统一卡片与控件的圆润度
- `--radius-sm: 6px` - 标签、小控件
- `--radius-md: 10px` - 卡片、表格、弹窗
- `--radius-lg: 16px` - 大区块、商品卡
- `--radius-full: 999px` - 胶囊按钮、角标、头像

## 间距 (Spacing) —— 8px 基准
- `--space-1: 4px` / `--space-2: 8px` / `--space-3: 12px` / `--space-4: 16px` / `--space-5: 24px` / `--space-6: 32px`

## 字号 (Font Size)
- `--font-sm: 12px` / `--font-md: 14px` / `--font-lg: 16px` / `--font-xl: 20px`

## 阴影 (Shadows)
- **Card**: `0 2px 8px rgba(0,0,0,.04)` (`var(--shadow-card)`) - 静置卡片
- **Base**: `0 4px 16px rgba(0,0,0,.08)` (`var(--shadow-base)`)
- **Hover**: `0 8px 24px rgba(0,0,0,.12)` (`var(--shadow-hover)`) - 悬浮态
- **Primary**: `0 8px 24px rgba(103,194,58,.18)` (`var(--shadow-primary)`) - 主色光晕，商品卡 hover 专用

## 过渡 (Transition)
- `--transition-fast: .2s ease` - 颜色、边框
- `--transition-base: .3s cubic-bezier(.25,1,.5,1)` - 位移、缩放

## 使用规范
1. **优先使用 CSS 变量**，禁止在页面内新增硬编码色值。
2. 价格统一用 `var(--color-price)`，不要用红色。
3. 红色只有一种：`var(--color-danger)`。
4. 商品卡片的 hover 阴影用 `var(--shadow-primary)`。

```css
.product-card {
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-card);
  transition: var(--transition-base);
}
.product-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-primary);
}
```
