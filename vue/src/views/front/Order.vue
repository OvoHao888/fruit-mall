<template>
  <div class="order-page">
    <front-header></front-header>
    <div class="main-content">
      <!-- 页面标题 -->
      <div class="page-header">
        <h2>我的订单</h2>
        <div class="order-count">共 {{ total }} 个订单</div>
      </div>

      <!-- 订单列表 -->
      <div class="order-content" v-loading="loading">
        <!-- 空订单提示 -->
        <el-empty v-if="!loading && orders.length === 0" :image-size="200" class="empty-order">
          <template slot="description">
            <div class="empty-text">
              <p class="main-text">您还没有任何订单</p>
              <p class="sub-text">快去选购心仪的商品吧</p>
            </div>
          </template>
          <el-button type="primary" size="medium" @click="$router.push('/products')">
            <i class="el-icon-shopping-cart-2"></i>
            去购物
          </el-button>
        </el-empty>

        <!-- 订单列表 -->
        <div v-else class="order-list">
          <div v-for="order in orders" :key="order.id" class="order-item">
            <div class="order-header">
              <span class="order-id">订单号：{{ order.id }}</span>
              <span class="order-time">{{ formatTime(order.createdAt) }}</span>
              <div class="status-wrapper">
                <span class="order-status" :class="getStatusClass(order.status)">
                  {{ getStatusText(order.status) }}
                </span>
                <i class="el-icon-delete delete-icon" @click="handleDelete(order)"></i>
              </div>
            </div>

            <!-- 修改订单商品和收货信息的布局 -->
            <div class="order-products">
              <div class="product-info">
                <el-image :src="order.product.imageUrl?.startsWith('http') ? order.product.imageUrl : `/api${order.product.imageUrl}`" fit="cover"
                  class="product-image">
                  <div slot="error" class="image-slot">
                    <i class="el-icon-picture-outline"></i>
                  </div>
                </el-image>
                <div class="product-details">
                  <h3 class="product-name">{{ order.product.name }}</h3>
                  <div class="product-price">
                    <span class="price" :class="{ 'discount': order.product.isDiscount }">
                      ¥{{ (order.product.isDiscount ? order.product.discountPrice : order.price).toFixed(2) }}
                    </span>
                    <span class="original-price" v-if="order.product.isDiscount">
                      ¥{{ order.product.price.toFixed(2) }}
                    </span>
                    <span class="quantity">x{{ order.quantity }}</span>
                  </div>
                  <!-- Add inventory and quantity controls -->
                  <div class="quantity-controls">
                    <span class="inventory">库存: {{ order.product.stock || 0 }}</span>
                    <div class="quantity-adjust" v-if="order.status === 0">
                      <el-input-number 
                        v-model="order.quantity" 
                        :min="1" 
                        :max="order.product.stock" 
                        size="small"
                        @change="handleQuantityChange(order)"
                      ></el-input-number>
                    </div>
                  </div>
                </div>
                <!-- 收货信息移到这里 -->
                <div class="delivery-info">
                  <div class="info-item">
                    <i class="el-icon-user"></i>
                    <span>{{ order.recvName || '暂无收货人' }}</span>
                  </div>
                  <div class="info-item">
                    <i class="el-icon-phone"></i>
                    <span>{{ order.recvPhone || '暂无联系电话' }}</span>
                  </div>
                  <div class="info-item">
                    <i class="el-icon-location"></i>
                    <span>{{ order.recvAddress || '暂无收货地址' }}</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="order-footer">
              <div class="order-total">
                总计：<span class="total-price">¥{{ order.totalPrice.toFixed(2) }}</span>
              </div>
              <div class="order-actions">
                <el-button v-if="order.status === 0" type="primary" size="small" @click="handlePayment(order)">
                  立即支付
                </el-button>
                <el-button v-if="order.status === 2" type="success" size="small" @click="handleConfirm(order)">
                  确认收货
                </el-button>
                <el-button v-if="order.status === 3" type="warning" size="small" @click="handleReview(order)">
                  评价
                </el-button>
                <el-button v-if="[1, 2, 3].includes(order.status)" type="danger" size="small" @click="showRefundDialog(order)">
                  申请退款
                </el-button>
                <el-button v-if="order.status === 0" type="danger" size="small" @click="handleCancel(order)">
                  取消订单
                </el-button>
                <el-button v-if="[0, 1].includes(order.status)" type="warning" size="small" @click="showAddressDialog(order)">
                  修改收货信息
                </el-button>
                <el-button 
                  v-if="order.status > 1" 
                  type="info" 
                  size="small" 
                  @click="handleViewLogistics(order)">
                  <i class="el-icon-truck"></i>
                  查看物流
                </el-button>
                <el-button 
                  v-if="order.status === 7" 
                  type="warning" 
                  size="small" 
                  @click="showInterventionDialog(order)">
                  申请平台介入
                </el-button>
                <el-button 
                  v-if="order.status === 8" 
                  type="info" 
                  size="small" 
                  @click="showInterventionDetail(order)">
                  查看拒绝原因
                </el-button>
                <el-button 
                  v-if="[3, 4, 6, 7, 8].includes(order.status)" 
                  type="danger" 
                  size="small" 
                  @click="handleDelete(order)">
                  <i class="el-icon-delete"></i>
                  删除订单
                </el-button>
              </div>
            </div>
          </div>
        </div>

        <!-- 分页 -->
        <div class="pagination-wrapper" v-if="total > 0">
          <el-pagination background :current-page.sync="currentPage" :page-size="pageSize" :total="total" layout="prev, pager, next, jumper"
            @current-change="getOrders">
          </el-pagination>
        </div>
      </div>
    </div>
    <front-footer></front-footer>

    <!-- 修改收货信息对话框 -->
    <el-dialog title="修改收货信息" :visible.sync="addressDialogVisible" width="500px" custom-class="address-dialog">
      <div v-if="!showAddressForm">
        <!-- 已有地址列表 -->
        <div class="address-list-section">
          <div class="section-header">
            <div class="section-title">
              <i class="el-icon-location"></i>
              选择收货地址
            </div>
            <el-button type="primary" plain size="small" @click="showAddressForm = true">
              <i class="el-icon-plus"></i>
              新增地址
            </el-button>
          </div>
          <div class="address-list">
            <el-radio-group v-model="selectedAddressId" class="address-radio-group">
              <el-radio v-for="addr in addresses" :key="addr.id" :label="addr.id" class="address-radio-item">
                <div class="address-content">
                  <div class="address-info">
                    <div class="contact-info">
                      <span class="receiver">{{ addr.receiver }}</span>
                      <span class="phone">{{ addr.phone }}</span>
                      <el-tag size="mini" type="success" v-if="addr.isDefault">默认地址</el-tag>
                    </div>
                    <div class="address-detail">{{ addr.address }}</div>
                  </div>
                  <div class="address-actions">
                    <el-button type="text" size="mini" @click.stop="editAddress(addr)">
                      <i class="el-icon-edit"></i>
                      编辑
                    </el-button>
                    <el-button type="text" size="mini" @click.stop="deleteAddress(addr)">
                      <i class="el-icon-delete"></i>
                      删除
                    </el-button>
                  </div>
                </div>
              </el-radio>
            </el-radio-group>
          </div>
        </div>
      </div>

      <!-- 新增地址表单 -->
      <div v-else>
        <div class="form-header">
          <div class="section-title">
            <i class="el-icon-plus"></i>
            新增地址
          </div>
          <el-button type="text" icon="el-icon-back" @click="showAddressForm = false">
            返回地址列表
          </el-button>
        </div>
        <el-form :model="addressForm" :rules="addressRules" ref="addressForm" label-width="80px" class="address-form">
          <el-form-item label="收货人" prop="receiver">
            <el-input v-model="addressForm.receiver" placeholder="请输入收货人">
              <template slot="prefix">
                <i class="el-icon-user"></i>
              </template>
            </el-input>
          </el-form-item>
          <el-form-item label="联系电话" prop="phone">
            <el-input v-model="addressForm.phone" placeholder="请输入联系电话">
              <template slot="prefix">
                <i class="el-icon-phone"></i>
              </template>
            </el-input>
          </el-form-item>
          <el-form-item label="收货地址" prop="address">
            <el-input type="textarea" v-model="addressForm.address" :rows="3" placeholder="请输入详细收货地址">
              <template slot="prefix">
                <i class="el-icon-location"></i>
              </template>
            </el-input>
          </el-form-item>
          <el-form-item>
            <el-checkbox v-model="saveToAddressBook">保存到地址簿</el-checkbox>
          </el-form-item>
        </el-form>
      </div>

      <div slot="footer" class="dialog-footer">
        <el-button @click="addressDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="updateOrderAddress">确定</el-button>
      </div>
    </el-dialog>

    <!-- 修改退款申请对话框 -->
    <el-dialog title="申请退款" :visible.sync="refundDialogVisible" width="400px">
      <el-form :model="refundForm" :rules="refundRules" ref="refundForm" label-width="80px">
        <el-form-item label="退款原因" prop="reason">
          <el-select v-model="refundForm.reason" placeholder="请选择退款原因" style="width: 100%">
            <el-option label="商品质量问题" value="商品质量问题"></el-option>
            <el-option label="商品与描述不符" value="商品与描述不符"></el-option>
            <el-option label="发货太慢" value="发货太慢"></el-option>
            <el-option label="其他原因" value="其他原因"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="refundDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="submitRefund">确 定</el-button>
      </div>
    </el-dialog>

    <!-- 修改评价对话框 -->
    <el-dialog title="商品评价" :visible.sync="reviewDialogVisible" width="500px">
      <div v-if="currentOrder" class="review-product-info">
        <el-image :src="currentOrder.product.imageUrl?.startsWith('http') ? currentOrder.product.imageUrl : `/api${currentOrder.product.imageUrl}`" fit="cover"
          class="review-product-image">
          <div slot="error" class="image-slot">
            <i class="el-icon-picture-outline"></i>
          </div>
        </el-image>
        <div class="review-product-detail">
          <div class="review-product-name">{{ currentOrder.product.name }}</div>
          <div class="review-product-price">
            <span class="price">¥{{ currentOrder.price.toFixed(2) }}</span>
            <span class="quantity">x {{ currentOrder.quantity }}</span>
          </div>
        </div>
      </div>

      <el-form :model="reviewForm" :rules="reviewRules" ref="reviewForm" label-width="80px" class="review-form" v-if="currentOrder">
        <el-form-item label="评分" prop="rating">
          <el-rate v-model="reviewForm.rating" :colors="['#99A9BF', '#F7BA2A', '#FF9900']" show-text :texts="['很差', '较差', '一般', '较好', '很好']">
          </el-rate>
        </el-form-item>
        <el-form-item label="评价内容" prop="content">
          <el-input type="textarea" v-model="reviewForm.content" :rows="4" placeholder="请分享您对商品的使用体验..."></el-input>
        </el-form-item>
      </el-form>

      <div slot="footer" class="dialog-footer">
        <el-button @click="reviewDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReview">提交评价</el-button>
      </div>
    </el-dialog>

    <!-- 添加删除订单对话框 -->
    <el-dialog
      title="删除订单"
      :visible.sync="deleteDialogVisible"
      width="30%">
      <span>确定要删除该订单吗？删除后将无法恢复。</span>
      <span slot="footer" class="dialog-footer">
        <el-button @click="deleteDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="confirmDelete">确定</el-button>
      </span>
    </el-dialog>

    <!-- 添加物流信息对话框 -->
    <el-dialog title="物流信息" :visible.sync="logisticsDialogVisible" width="600px">
      <div class="logistics-info" v-if="logisticsInfo">
        <div class="logistics-header">
          <div class="company-info">
            <span class="label">快递公司：</span>
            <span>{{ logisticsInfo.companyName }}</span>
          </div>
          <div class="tracking-info">
            <span class="label">快递单号：</span>
            <span>{{ logisticsInfo.trackingNumber }}</span>
          </div>
          <div class="status-info">
            <span class="label">物流状态：</span>
            <el-tag :type="getLogisticsStatusType(logisticsInfo.status)">
              {{ logisticsStatusMap[logisticsInfo.status] }}
            </el-tag>
          </div>
          <div class="time-info">
            <div>
              <span class="label">创建时间：</span>
              <span>{{ formatTime(logisticsInfo.createdAt) }}</span>
            </div>
            <div>
              <span class="label">更新时间：</span>
              <span>{{ formatTime(logisticsInfo.updatedAt) }}</span>
            </div>
          </div>
        </div>
        <div class="logistics-address">
          <h4>收货信息</h4>
          <div class="address-content">
            <div class="address-item">
              <span class="label">收货人：</span>
              <span class="value">{{ logisticsInfo.receiverName }}</span>
            </div>
            <div class="address-item">
              <span class="label">联系电话：</span>
              <span class="value">{{ logisticsInfo.receiverPhone }}</span>
            </div>
            <div class="address-item">
              <span class="label">收货地址：</span>
              <span class="value">{{ logisticsInfo.receiverAddress }}</span>
            </div>
          </div>
        </div>
        <div class="logistics-arrival">
          <span class="label">预计到达：</span>
          <span class="value">{{ formatTime(logisticsInfo.expectedArrivalTime) }}</span>
        </div>
      </div>
    </el-dialog>

    <!-- 申请平台介入对话框 -->
    <el-dialog title="申请平台介入" :visible.sync="interventionDialogVisible" width="500px">
      <div v-if="currentInterventionOrder" class="intervention-order-info">
        <div class="order-summary">
          <el-image :src="currentInterventionOrder.product.imageUrl?.startsWith('http') ? currentInterventionOrder.product.imageUrl : `/api${currentInterventionOrder.product.imageUrl}`" fit="cover" class="product-img">
            <div slot="error" class="image-slot">
              <i class="el-icon-picture-outline"></i>
            </div>
          </el-image>
          <div class="product-info">
            <div class="product-name">{{ currentInterventionOrder.product.name }}</div>
            <div class="order-amount">订单金额：¥{{ currentInterventionOrder.totalPrice.toFixed(2) }}</div>
          </div>
        </div>
      </div>
      <el-form :model="interventionForm" :rules="interventionRules" ref="interventionForm" label-width="100px">
        <el-form-item label="申请原因" prop="reason">
          <el-input type="textarea" v-model="interventionForm.reason" :rows="4" placeholder="请详细说明申请平台介入的原因..."></el-input>
        </el-form-item>
        <el-form-item label="上传图片">
          <el-upload
            action="/api/files/upload"
            :headers="{ token: userInfo.token }"
            list-type="picture-card"
            :file-list="interventionForm.fileList"
            :on-success="handleInterventionImageSuccess"
            :on-remove="handleInterventionImageRemove"
            :limit="5">
            <i class="el-icon-plus"></i>
            <div slot="tip" class="el-upload__tip">最多上传5张图片作为证据</div>
          </el-upload>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="interventionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitIntervention" :loading="interventionLoading">提交申请</el-button>
      </div>
    </el-dialog>

    <!-- 查看拒绝原因对话框 -->
    <el-dialog title="拒绝原因" :visible.sync="interventionDetailVisible" width="500px">
      <div v-if="interventionDetail" class="intervention-detail">
        <div class="detail-item">
          <span class="label">申请时间：</span>
          <span>{{ formatTime(interventionDetail.createdAt) }}</span>
        </div>
        <div class="detail-item">
          <span class="label">申请原因：</span>
          <span>{{ interventionDetail.reason }}</span>
        </div>
        <div class="detail-item" v-if="interventionDetail.adminReply">
          <span class="label">拒绝原因：</span>
          <span class="reject-reason">{{ interventionDetail.adminReply }}</span>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="interventionDetailVisible = false">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import FrontHeader from '@/components/front/FrontHeader.vue'
import FrontFooter from '@/components/front/FrontFooter.vue'
import Request from '@/utils/request'
import { formatTime } from '@/utils/time'

export default {
  name: 'Order',
  components: {
    FrontHeader,
    FrontFooter
  },
  data() {
    return {
      userInfo: JSON.parse(localStorage.getItem('frontUser') || '{}'),
      loading: false,
      orders: [],
      currentPage: 1,
      pageSize: 10,
      total: 0,
      paymentDialogVisible: false,
      paymentMethod: 'balance',
      currentOrder: null,
      addressDialogVisible: false,
      selectedAddressId: null,
      addresses: [],
      saveToAddressBook: false,
      addressForm: {
        id: '',
        receiver: '',
        phone: '',
        address: ''
      },
      currentEditOrder: null,
      addressRules: {
        receiver: [
          { required: true, message: '请输入收货人', trigger: 'blur' }
        ],
        phone: [
          { required: true, message: '请输入联系电话', trigger: 'blur' },
          { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
        ],
        address: [
          { required: true, message: '请输入收货地址', trigger: 'blur' }
        ]
      },
      showAddressForm: false,
      refundDialogVisible: false,
      refundForm: {
        reason: ''
      },
      refundRules: {
        reason: [
          { required: true, message: '请选择退款原因', trigger: 'change' }
        ]
      },
      currentRefundOrder: null,
      reviewDialogVisible: false,
      reviewForm: {
        rating: 5,
        content: ''
      },
      reviewRules: {
        rating: [
          { required: true, message: '请选择评分', trigger: 'change' }
        ],
        content: [
          { required: true, message: '请填写评价内容', trigger: 'blur' },
          { min: 5, max: 500, message: '评价内容长度在 5 到 500 个字符', trigger: 'blur' }
        ]
      },
      deleteDialogVisible: false,
      currentDeleteOrder: null,
      logisticsDialogVisible: false,
      logisticsInfo: null,
      logisticsStatusMap: {
        0: '待发货',
        1: '已发货',
        2: '已签收',
        3: '已取消'
      },
      interventionDialogVisible: false,
      currentInterventionOrder: null,
      interventionForm: {
        reason: '',
        images: [],
        fileList: []
      },
      interventionRules: {
        reason: [
          { required: true, message: '请填写申请原因', trigger: 'blur' },
          { min: 10, max: 500, message: '申请原因长度在 10 到 500 个字符', trigger: 'blur' }
        ]
      },
      interventionLoading: false,
      interventionDetailVisible: false,
      interventionDetail: null
    }
  },
  created() {
    this.getOrders()
  },
  mounted() {
    this.userInfo = JSON.parse(localStorage.getItem('frontUser') || '{}')
  },
  methods: {
    isLogin() {
      const userStr = localStorage.getItem('frontUser')
      if (!userStr) {
        this.$message({
          type: 'warning',
          message: '请先登录'
        })
        this.$router.push('/login')
        return false
      }
      return true
    },
    formatTime,
    async getOrders() {
      this.isLogin()
      this.loading = true
      try {
        const userId = this.userInfo.id
        const res = await Request.get('/order/page', {
          params: {
            userId,
            currentPage: this.currentPage,
            size: this.pageSize
          }
        })
        if (res.code === '0') {
          if (res.data.total === 0) {
            this.orders = []
            this.total = 0
          } else {
            this.orders = res.data.records
            this.total = res.data.total
          }
        }
      } catch (error) {
        console.error('获取订单列表失败:', error)
        this.$message.error('获取订单列表失败')
      } finally {
        this.loading = false
      }
        
      },

      getStatusText(status) {
        const statusMap = {
          0: '待支付',
          1: '已支付',
          2: '已发货',
          3: '已完成',
          4: '已取消',
          5: '退款中',
          6: '已退款',
          7: '退款失败',
          8: '已拒绝退款申请'
        }
        return statusMap[status] || '未知状态'
      },

      getStatusClass(status) {
        const classMap = {
          0: 'pending',
          1: 'paid',
          2: 'shipped',
          3: 'completed',
          4: 'cancelled',
          5: 'refunding',
          6: 'refunded',
          7: 'refund-failed',
          8: 'intervention-rejected'
        }
        return classMap[status] || ''
      },

      async handleConfirm(order) {
        try {
          await this.$confirm('确认已收到商品吗？', '提示', {
            type: 'warning'
          })
          const res = await Request.put(`/order/${order.id}/status?status=3`);
          if (res.code === '0') {
            this.$message.success('确认收货成功')
            this.getOrders()
          }
        } catch (error) {
          if (error !== 'cancel') {
            console.error('确认收货失败:', error)
            this.$message.error('确认收货失败')
          }
        }
      },

      handleReview(order) {
        // 确保order包含完整的商品信息
        this.currentOrder = {
          ...order,
          product: {
            ...order.product
          }
        }
        this.reviewForm = {
          rating: 5,
          content: ''
        }
        this.reviewDialogVisible = true
      },

    async handleCancel(order) {
        this.isLogin()
        try {
          await this.$confirm('确定要取消订单吗？', '提示', {
            type: 'warning'
          })
          const res = await Request.put(`/order/${order.id}/status?status=4`);
          if (res.code === '0') {
            this.$message.success('订单已取消')
            this.getOrders()
          }
        } catch (error) {
          if (error !== 'cancel') {
            console.error('取消订单失败:', error)
            this.$message.error('取消订单失败')
          }
        }
      },

    async getAddresses() {
        this.isLogin()
        try {
          const userId = this.userInfo.id
          const res = await Request.get(`/address/user/${userId}`)
          if (res.code === '0') {
            this.addresses = res.data
          }
        } catch (error) {
          console.error('获取地址列表失败:', error)
          this.$message.error('获取地址列表失败')
        }
      },

      // 添加编辑地址方法
      editAddress(address) {
        this.showAddressForm = true
        this.addressForm = {
          id: address.id,
          receiver: address.receiver,
          phone: address.phone,
          address: address.address
        }
      },

      // 添加删除地址方法
      async deleteAddress(address) {
        try {
          await this.$confirm('确定要删除该地址吗？', '提示', {
            type: 'warning'
          })
          const res = await Request.delete(`/address/${address.id}`)
          if (res.code === '0') {
            this.$message.success('删除地址成功')
            this.getAddresses() // 刷新地址列表
          }
        } catch (error) {
          if (error !== 'cancel') {
            console.error('删除地址失败:', error)
            this.$message.error('删除地址失败')
          }
        }
      },

      formatAddress(addr) {
        return `${addr.receiver ? addr.receiver + ' ' : ''}${addr.phone} ${addr.address}`
      },

      showAddressDialog(order) {
        this.currentEditOrder = order
        this.addressForm = {
          id: '',
          receiver: order.recvName || '',
          phone: order.recvPhone || '',
          address: order.recvAddress || ''
        }
        this.selectedAddressId = null
        this.saveToAddressBook = false
        this.showAddressForm = false
        this.addressDialogVisible = true
        this.getAddresses()
      },

    async updateOrderAddress() {
      try {
        if (this.showAddressForm) {
          // 如果是新增地址，验证表单
          await this.$refs.addressForm.validate()
        } else if (!this.selectedAddressId) {
          // 如果是选择已有地址，验证是否已选择
          this.$message.warning('请选择收货地址')
          return
        }

        let receiver, phone, address, addressId
        if (this.showAddressForm) {
          // 使用表单数据
          receiver = this.addressForm.receiver
          phone = this.addressForm.phone
          address = this.addressForm.address
          addressId = this.addressForm.id // 获取地址ID，用于判断是新增还是编辑

          // 如果有地址ID，说明是编辑已有地址
          if (addressId) {
            // 更新地址簿中的地址
            const updateRes = await Request.put(`/address/${addressId}`, {
              id: addressId,
              userId: this.userInfo.id,
              receiver,
              phone,
              address
            })
            if (updateRes.code !== '0') {
              this.$message.error('更新地址失败')
              return
            }
          } else if (this.saveToAddressBook) {
            // 如果是新地址且需要保存到地址簿
            const userId = this.userInfo.id
            await Request.post('/address', {
              userId,
              receiver,
              phone,
              address
            })
          }
        } else {
          // 使用选中的地址
          const selectedAddress = this.addresses.find(addr => addr.id === this.selectedAddressId)
          receiver = selectedAddress.receiver
          phone = selectedAddress.phone
          address = selectedAddress.address
        }

        // 更新订单收货信息
        const orderRes = await Request.put(`/order/${this.currentEditOrder.id}/address`, null, {
          params: {
            name: receiver,
            address,
            phone
          }
        })

        if (orderRes.code === '0') {
          this.$message.success('收货信息更新成功')
          this.addressDialogVisible = false
          this.getOrders() // 刷新订单列表
        }
      } catch (error) {
        if (error !== 'cancel') {
          console.error('更新收货信息失败:', error)
          this.$message.error('更新收货信息失败')
        }
      }
    },

      // 显示退款对话框
      showRefundDialog(order) {
        this.currentRefundOrder = order
        this.refundForm = {
          reason: ''
        }
        this.refundDialogVisible = true
      },

      // 提交退款申请
      submitRefund() {
        this.$refs.refundForm.validate(async (valid) => {
          if (valid) {
            try {
              const res = await Request.post(`/order/${this.currentRefundOrder.id}/refund?reason=${encodeURIComponent(this.refundForm.reason)}`);

              if (res.code === '0') {
                this.$message.success('退款申请已提交，请等待商家处理')
                this.refundDialogVisible = false
                this.getOrders()
              } else {
                this.$message.error(res.msg || '退款申请失败')
              }
            } catch (error) {
              console.error('退款申请失败:', error)
              this.$message.error('退款申请失败')
            }
          }
        })
      },

    // 提交评价
    async submitReview() {
        try {
          await this.$refs.reviewForm.validate()
          this.isLogin()
          const reviewData = {
            userId: this.userInfo.id,
            productId: this.currentOrder.product.id,
            rating: this.reviewForm.rating,
            content: this.reviewForm.content
          }

          const res = await Request.post('/review', reviewData)
          if (res.code === '0') {
            this.$message.success('评价成功')
            this.reviewDialogVisible = false
            // 更新订单状态为已评价
            await Request.put(`/order/${this.currentOrder.id}/status?status=3`)
            this.getOrders()
          }
        } catch (error) {
          if (error !== 'cancel') {
            console.error('评价失败:', error)
            this.$message.error('评价失败')
          }
        }
      },
    async handleQuantityChange(order) {
      try {
        // 创建更新订单对象
        const updateOrder = {
          id: order.id,
          quantity: order.quantity,
          totalPrice: order.quantity * (order.product.isDiscount ? order.product.discountPrice : order.price)
        };

        const res = await Request.put(`/order/${order.id}`, updateOrder);
        
        if (res.code === '0') {
          // 更新本地订单总价
          order.totalPrice = updateOrder.totalPrice;
          this.$message.success('数量修改成功');
        } else {
          this.$message.error(res.msg || '修改失败');
          // 修改失败时重新获取订单列表
          this.getOrders();
        }
      } catch (error) {
        console.error('修改数量失败:', error);
        this.$message.error('修改数量失败');
        // 修改失败时重新获取订单列表
        this.getOrders();
      }
    },
    handleDelete(order) {
      this.currentDeleteOrder = order;
      this.deleteDialogVisible = true;
    },
    async confirmDelete() {
      try {
        const res = await Request.delete(`/order/${this.currentDeleteOrder.id}`);
        if (res.code === '0') {
          this.$message.success('订单删除成功');
          this.deleteDialogVisible = false;
          this.getOrders(); // 刷新订单列表
        } else {
          this.$message.error(res.msg || '删除失败');
        }
      } catch (error) {
        console.error('删除订单失败:', error);
        this.$message.error('删除订单失败');
      }
    },
    // 获取物流状态对应的类型
    getLogisticsStatusType(status) {
      const typeMap = {
        0: 'info',
        1: 'primary',
        2: 'success',
        3: 'danger'
      }
      return typeMap[status] || 'info'
    },
    // 查看物流信息
    async handleViewLogistics(order) {
      try {
        const res = await Request.get(`/logistics/order/${order.id}`)
        if (res.code === '0') {
          this.logisticsInfo = res.data
          this.logisticsDialogVisible = true
        } else {
          this.$message.error(res.msg || '暂无物流信息')
        }
      } catch (error) {
        console.error('获取物流信息失败:', error)
        this.$message.error('获取物流信息失败')
      }
    },
    showInterventionDialog(order) {
      this.currentInterventionOrder = order
      this.interventionForm = {
        reason: '',
        images: [],
        fileList: []
      }
      this.interventionDialogVisible = true
    },
    handleInterventionImageSuccess(res, file, fileList) {
      if (res.code === '0') {
        this.interventionForm.images.push(res.data)
      }
    },
    handleInterventionImageRemove(file, fileList) {
      const url = file.response ? file.response.data : file.url
      const index = this.interventionForm.images.indexOf(url)
      if (index > -1) {
        this.interventionForm.images.splice(index, 1)
      }
    },
    async submitIntervention() {
      try {
        await this.$refs.interventionForm.validate()
        this.interventionLoading = true
        
        const data = {
          orderId: this.currentInterventionOrder.id,
          reason: this.interventionForm.reason,
          images: JSON.stringify(this.interventionForm.images)
        }
        
        const res = await Request.post('/refund-intervention', data)
        if (res.code === '0') {
          this.$message.success('申请已提交，请等待管理员审核')
          this.interventionDialogVisible = false
          this.getOrders()
        } else {
          this.$message.error(res.msg || '提交失败')
        }
      } catch (error) {
        console.error('提交申请失败:', error)
      } finally {
        this.interventionLoading = false
      }
    },
    async showInterventionDetail(order) {
      try {
        const res = await Request.get(`/refund-intervention/order/${order.id}`)
        if (res.code === '0' && res.data) {
          this.interventionDetail = res.data
          this.interventionDetailVisible = true
        } else {
          this.$message.error('获取详情失败')
        }
      } catch (error) {
        console.error('获取详情失败:', error)
        this.$message.error('获取详情失败')
      }
    },
    // 添加支付处理方法
    async handlePayment(order) {
      if(!this.isLogin()) return;
      
      try {
        // 获取商品信息，展示更详细的支付信息
        const productName = order.product.name;
        const quantity = order.quantity;
        
        // 添加确认支付对话框
        await this.$confirm(
          `<div class="payment-confirm">
            <div class="payment-info">
              <p class="product-name">${productName} × ${quantity}</p>
              <p class="order-info">订单号: ${order.id}</p>
              <div class="payment-amount">
                <span>支付金额:</span>
                <span class="amount">¥${order.totalPrice.toFixed(2)}</span>
              </div>
            </div>
          </div>`, 
          '确认支付', 
          {
            confirmButtonText: '确认支付',
            cancelButtonText: '取消',
            type: 'warning',
            center: true,
            dangerouslyUseHTMLString: true,
            customClass: 'payment-confirm-dialog'
          }
        );
        
        // 显示加载中
        const loading = this.$loading({
          lock: true,
          text: '支付处理中...',
          spinner: 'el-icon-loading',
          background: 'rgba(255, 255, 255, 0.7)'
        });
        
        // 使用余额支付
        const res = await Request.put(`/order/${order.id}/pay`);
        
        // 关闭加载
        loading.close();

        if (res.code === '0') {
          this.$message({
            type: 'success',
            message: '支付成功',
            duration: 2000
          });
          this.getOrders(); // 刷新订单列表
        } else {
          this.$message.error(res.msg || '支付失败');
        }
      } catch (error) {
        if (error === 'cancel') {
          this.$message({
            type: 'info',
            message: '已取消支付'
          });
        } else {
          console.error('支付失败:', error);
          this.$message.error('支付失败，请稍后重试');
        }
      }
    },
  },
  computed: {
    orderStatusText() {
      const statusMap = {
        0: '待支付',
        1: '已支付',
        2: '已发货',
        3: '已完成',
        4: '已取消',
        5: '退款中',
        6: '已退款',
        7: '退款失败'
      }
      return (status) => statusMap[status] || '未知状态'
    },

    orderStatusType() {
      const typeMap = {
        0: 'warning',
        1: 'primary',
        2: 'success',
        3: 'success',
        4: 'info',
        5: 'warning',
        6: 'info',
        7: 'danger'
      }
      return (status) => typeMap[status] || 'info'
    },
  },
}
</script>

<style scoped>
.order-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #f8faf5 0%, var(--bg-body) 100%);
}

.main-content {
  flex: 1;
  padding: 40px;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
}

/* 页面标题样式 */
.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
  background: white;
  padding: 20px 24px;
  border-radius: 12px;
  border: 1px solid var(--border-color-light);
  position: relative;
  overflow: hidden;
}

.page-header::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(to bottom, var(--color-primary), var(--color-primary-dark));
}

.page-header h2 {
  font-size: 24px;
  font-weight: 500;
  color: var(--text-main);
  margin: 0;
}

.order-count {
  color: var(--text-regular);
  font-size: 14px;
  font-weight: 500;
  background: rgba(103, 194, 58, 0.1);
  padding: 6px 16px;
  border-radius: 20px;
}

/* 订单列表样式 */
.order-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.order-item {
  background: white;
  border-radius: 12px;
  padding: 20px 24px;
  border: 1px solid var(--border-color-light);
  position: relative;
  overflow: hidden;
}

.order-item::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 3px;
  height: 100%;
  background: linear-gradient(to bottom, var(--color-primary), var(--color-primary-dark));
  opacity: 0;
  transition: opacity 0.3s ease;
}

.order-item:hover::before {
  opacity: 1;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--bg-body);
  margin-bottom: 16px;
}

.order-id {
  color: var(--text-regular);
  font-size: 14px;
}

.order-time {
  color: var(--text-secondary);
  font-size: 14px;
}

.status-wrapper {
  display: flex;
  align-items: center;
  gap: 16px;
}

.order-status {
  font-size: 13px;
  font-weight: 500;
  padding: 4px 12px;
  border-radius: 6px;
  position: relative;
  overflow: hidden;
}

.order-status::before {
  content: '';
  position: absolute;
  inset: 0;
  background: currentColor;
  opacity: 0.1;
}

.order-status.pending {
  color: #e6a23c;
  background: rgba(230, 162, 60, 0.1);
}

.order-status.paid {
  color: var(--color-accent);
  background: rgba(255, 125, 0, 0.1);
}

.order-status.shipped {
  color: var(--color-primary);
  background: rgba(103, 194, 58, 0.1);
}

.order-status.completed {
  color: var(--color-primary);
  background: rgba(103, 194, 58, 0.1);
}

.order-status.cancelled {
  color: var(--text-secondary);
  background: rgba(144, 147, 153, 0.1);
}

.order-status.refunding {
  color: #e6a23c;
  background: rgba(230, 162, 60, 0.1);
}

.order-status.refunded {
  color: var(--text-secondary);
  background: rgba(144, 147, 153, 0.1);
}

.order-status.refund-failed {
  color: var(--color-danger);
  background: rgba(245, 108, 108, 0.1);
}

.order-products {
  padding: 20px 0;
  margin-top: 16px;
}

.product-info {
  display: grid;
  grid-template-columns: 80px 1fr 300px;
  gap: 20px;
  align-items: center;
}

.product-image {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.product-image:hover {
  transform: scale(1.02);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.product-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.product-name {
  margin: 0;
  font-size: 16px;
  color: var(--text-main);
}

.product-price {
  display: flex;
  align-items: center;
  gap: 8px;
}

.price {
  color: var(--color-danger);
  font-size: 16px;
  font-weight: 600;
}

.price.discount {
  color: var(--color-danger);
  font-weight: 700;
}

.original-price {
  color: var(--text-secondary);
  font-size: 13px;
  text-decoration: line-through;
  margin: 0 8px;
}

.quantity {
  color: var(--text-secondary);
  font-size: 14px;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 16px;
  border-top: 1px solid var(--border-color-light);
}

.order-total {
  color: var(--text-regular);
  font-size: 14px;
}

.total-price {
  color: var(--color-danger);
  font-size: 18px;
  font-weight: 600;
}

.order-actions {
  display: flex;
  gap: 8px;
}

.order-actions .el-button {
  padding: 8px 16px;
  font-size: 13px;
  border-radius: 6px;
  position: relative;
  overflow: hidden;
}

.order-actions .el-button::before {
  content: '';
  position: absolute;
  inset: 0;
  background: currentColor;
  opacity: 0.1;
  transition: opacity 0.3s ease;
}

.order-actions .el-button:hover::before {
  opacity: 0.15;
}

/* 分页样式 */
.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin: 40px 0;
  padding: 20px 0;
}

:deep(.el-pagination.is-background .el-pager li:not(.disabled).active) {
  background-color: var(--color-primary);
}

:deep(.el-pagination.is-background .el-pager li:not(.disabled):hover) {
  color: var(--color-primary);
}

/* 加载状态样式 */
:deep(.el-loading-mask) {
  background-color: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(4px);
}

.payment-options {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

/* 修改收货信息样式 */
.delivery-info {
  background: #f8faf5;
  border-radius: 8px;
  padding: 12px 16px;
  position: relative;
  overflow: hidden;
}

.delivery-info::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(103, 194, 58, 0.05), transparent);
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-regular);
  font-size: 14px;
}

.info-item i {
  color: var(--color-primary);
  font-size: 16px;
}

.info-item span {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: var(--text-regular);
}

/* 添加空值样式 */
.info-item span:empty::before,
.info-item span:only-child {
  content: "暂无信息";
  color: var(--text-secondary);
  font-style: italic;
}

/* 修改收货信息按钮样式 */
.order-actions .el-button--warning {
  background: linear-gradient(135deg, #f0ad4e, #ff9800);
  border: none;
  color: white;
}

.order-actions .el-button--warning:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(240, 173, 78, 0.3);
}

/* 对话框样式优化 */
:deep(.el-dialog) {
  border-radius: 8px;
  overflow: hidden;
}

:deep(.el-dialog__header) {
  padding: 20px;
  border-bottom: 1px solid var(--bg-body);
  margin: 0;
}

:deep(.el-dialog__body) {
  padding: 24px 20px;
  max-height: 60vh;
  overflow-y: auto;
}

:deep(.el-dialog__footer) {
  padding: 16px 20px;
  border-top: 1px solid var(--bg-body);
  margin-top: 0;
}

.address-select-section {
  margin-bottom: 24px;
}

.section-title {
  font-size: 14px;
  color: var(--text-regular);
  margin-bottom: 12px;
}

.address-select {
  width: 100%;
}

/* 自定义滚动条样式 */
:deep(.el-dialog__body::-webkit-scrollbar) {
  width: 6px;
}

:deep(.el-dialog__body::-webkit-scrollbar-thumb) {
  background: rgba(144, 147, 153, 0.3);
  border-radius: 3px;
}

:deep(.el-dialog__body::-webkit-scrollbar-track) {
  background: transparent;
}

/* 地址列表样式优化 */
.address-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 20px;
}

.address-radio-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

.address-radio-item {
  width: 100%;
  margin: 0;
  padding: 12px;
  border: 1px solid var(--border-color-base);
  border-radius: 8px;
  transition: all 0.3s ease;
  display: flex !important;
  align-items: flex-start;
}

.address-radio-item:hover {
  border-color: var(--color-primary);
}

.address-radio-item.is-checked {
  border-color: var(--color-primary);
  background: #f0f9eb;
}

.address-content {
  margin-left: 8px;
  flex: 1;
  overflow: hidden;
}

.address-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.contact-info {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.receiver {
  font-weight: 500;
  color: var(--text-main);
  font-size: 15px;
  margin-right: 8px;
}

.phone {
  color: var(--text-regular);
  font-size: 14px;
}

.address-detail {
  color: var(--text-regular);
  font-size: 14px;
  line-height: 1.5;
  word-break: break-all;
}

.address-actions {
  display: flex;
  gap: 8px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.address-radio-item:hover .address-actions {
  opacity: 1;
}

.address-actions .el-button {
  padding: 4px 8px;
  font-size: 13px;
}

.address-actions .el-button i {
  margin-right: 4px;
  font-size: 14px;
}

.address-form {
  padding: 20px 0;
}

:deep(.el-input__prefix) {
  color: var(--color-primary);
}

:deep(.el-input__inner),
:deep(.el-textarea__inner) {
  border-color: var(--border-color-base);
  transition: all 0.3s ease;
}

:deep(.el-input__inner:hover),
:deep(.el-textarea__inner:hover) {
  border-color: var(--color-primary);
}

:deep(.el-input__inner:focus),
:deep(.el-textarea__inner:focus) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(103, 194, 58, 0.1);
}

:deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background-color: var(--color-primary);
  border-color: var(--color-primary);
}

:deep(.el-checkbox__inner:hover) {
  border-color: var(--color-primary);
}

/* 自定义滚动条样式 */
.address-list::-webkit-scrollbar {
  width: 6px;
}

.address-list::-webkit-scrollbar-thumb {
  background: rgba(144, 147, 153, 0.3);
  border-radius: 3px;
}

.address-list::-webkit-scrollbar-track {
  background: transparent;
}

/* 空地址列表样式 */
.empty-address {
  text-align: center;
  padding: 40px 0;
  color: var(--text-secondary);
}

.empty-address i {
  font-size: 48px;
  margin-bottom: 16px;
  color: var(--border-color-base);
}

.empty-address p {
  margin: 8px 0;
  font-size: 14px;
}

/* 地址对话框样式优化 */
:deep(.address-dialog) {
  border-radius: 12px;
  overflow: hidden;
}

:deep(.address-dialog .el-dialog__header) {
  padding: 20px 24px;
  border-bottom: 1px solid var(--bg-body);
  background: #f8faf5;
}

:deep(.address-dialog .el-dialog__title) {
  font-size: 18px;
  font-weight: 500;
  color: var(--text-main);
}

:deep(.address-dialog .el-dialog__body) {
  padding: 24px;
}

:deep(.address-dialog .el-dialog__footer) {
  padding: 16px 24px;
  border-top: 1px solid var(--bg-body);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 500;
  color: var(--text-main);
}

.section-title i {
  color: var(--color-primary);
  font-size: 18px;
}

.address-list {
  max-height: 400px;
  overflow-y: auto;
  padding-right: 8px;
}

.address-radio-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-radio-item {
  width: 100%;
  margin: 0;
  padding: 16px;
  border: 1px solid var(--border-color-base);
  border-radius: 8px;
  transition: all 0.3s ease;
  background: #fff;
}

.address-radio-item:hover {
  border-color: var(--color-primary);
  box-shadow: 0 2px 12px rgba(103, 194, 58, 0.1);
}

.address-radio-item.is-checked {
  border-color: var(--color-primary);
  background: #f0f9eb;
}

.address-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.address-info {
  flex: 1;
}

.contact-info {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.receiver {
  font-weight: 500;
  color: var(--text-main);
  font-size: 15px;
}

.phone {
  font-weight: 500;
  color: var(--text-main);
  font-size: 15px;
}

.address-detail {
  color: var(--text-regular);
  font-size: 14px;
  line-height: 1.5;
  word-break: break-all;
}

.address-actions {
  display: flex;
  gap: 8px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.address-radio-item:hover .address-actions {
  opacity: 1;
}

.address-actions .el-button {
  padding: 4px 8px;
  font-size: 13px;
}

.address-actions .el-button i {
  margin-right: 4px;
  font-size: 14px;
}

.address-form {
  padding: 20px 0;
}

:deep(.el-input__prefix) {
  color: var(--color-primary);
}

:deep(.el-input__inner),
:deep(.el-textarea__inner) {
  border-color: var(--border-color-base);
  transition: all 0.3s ease;
}

:deep(.el-input__inner:hover),
:deep(.el-textarea__inner:hover) {
  border-color: var(--color-primary);
}

:deep(.el-input__inner:focus),
:deep(.el-textarea__inner:focus) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(103, 194, 58, 0.1);
}

:deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background-color: var(--color-primary);
  border-color: var(--color-primary);
}

:deep(.el-checkbox__inner:hover) {
  border-color: var(--color-primary);
}

/* 自定义滚动条样式 */
.address-list::-webkit-scrollbar {
  width: 6px;
}

.address-list::-webkit-scrollbar-thumb {
  background: rgba(144, 147, 153, 0.3);
  border-radius: 3px;
}

.address-list::-webkit-scrollbar-track {
  background: transparent;
}

/* 空地址列表样式 */
.empty-address {
  text-align: center;
  padding: 40px 0;
  color: var(--text-secondary);
}

.empty-address i {
  font-size: 48px;
  margin-bottom: 16px;
  color: var(--border-color-base);
}

.empty-address p {
  margin: 8px 0;
  font-size: 14px;
}

/* 物流信息对话框样式 */
.logistics-info {
  padding: 20px;
}

.logistics-header {
  background: var(--bg-body);
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.logistics-header > div {
  margin-bottom: 12px;
}

.logistics-header > div:last-child {
  margin-bottom: 0;
}

.logistics-header .label {
  color: var(--text-secondary);
  margin-right: 8px;
}

.time-info {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px dashed #e4e7ed;
}

.time-info > div {
  margin-bottom: 8px;
}

.logistics-address {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
}

.logistics-address h4 {
  font-size: 16px;
  color: var(--text-main);
  margin: 0 0 16px 0;
}

.address-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.address-item {
  display: flex;
  align-items: flex-start;
  font-size: 14px;
  line-height: 1.5;
}

.address-item .label {
  color: var(--text-regular);
  width: 80px;
  flex-shrink: 0;
}

.address-item .value {
  color: var(--text-main);
  flex: 1;
  word-break: break-all;
}

/* 物流按钮样式 */
.order-actions .el-button--info {
  background: linear-gradient(135deg, var(--text-secondary), var(--text-regular));
  border: none;
  color: white;
}

.order-actions .el-button--info:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(144, 147, 153, 0.3);
}

.order-actions .el-button--info i {
  margin-right: 4px;
}

.logistics-arrival {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px dashed #e4e7ed;
  display: flex;
  align-items: center;
}

.logistics-arrival .label {
  width: 80px;
  color: var(--text-regular);
  font-size: 14px;
  flex-shrink: 0;
}

.logistics-arrival .value {
  color: #ff6b00;
  font-size: 16px;
  font-weight: 600;
}

/* 支付确认对话框样式 */
:deep(.payment-confirm-dialog) {
  border-radius: 12px;
  overflow: hidden;
}

:deep(.payment-confirm-dialog .el-message-box__header) {
  background: #f8faf5;
  padding: 16px 20px;
}

:deep(.payment-confirm-dialog .el-message-box__title) {
  color: var(--text-main);
  font-size: 18px;
  font-weight: 600;
}

:deep(.payment-confirm-dialog .el-message-box__content) {
  padding: 20px;
  padding-bottom: 10px;
}

:deep(.payment-confirm-dialog .el-message-box__btns) {
  padding: 12px 20px;
  border-top: 1px solid var(--bg-body);
}

:deep(.payment-confirm-dialog .el-button--primary) {
  background: linear-gradient(135deg, var(--color-primary), var(--color-primary-dark));
  border: none;
  box-shadow: 0 4px 12px rgba(103, 194, 58, 0.2);
}

:deep(.payment-confirm-dialog .el-button--primary:hover) {
  background: linear-gradient(135deg, #5ab82f, #79c152);
  transform: translateY(-1px);
  box-shadow: 0 6px 15px rgba(103, 194, 58, 0.25);
}

.payment-confirm {
  padding: 10px;
}

.payment-info {
  background: #f8faf5;
  border-radius: 8px;
  padding: 16px;
  border: 1px dashed rgba(103, 194, 58, 0.3);
}

.payment-info .product-name {
  font-size: 16px;
  font-weight: 500;
  color: var(--text-main);
  margin: 0 0 12px 0;
}

.payment-info .order-info {
  font-size: 14px;
  color: var(--text-regular);
  margin: 8px 0;
}

.payment-amount {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px dashed #e4e7ed;
}

.payment-amount .amount {
  font-size: 20px;
  font-weight: 600;
  color: var(--color-danger);
}

/* 评价相关样式优化 */
.review-product-info {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #f8faf5;
  border-radius: 8px;
  margin-bottom: 24px;
  align-items: flex-start;
}

.review-product-image {
  width: 80px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden;
  flex-shrink: 0;
  border: 1px solid var(--border-color-light);
}

.review-product-detail {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
  justify-content: center;
  min-height: 80px;
}

.review-product-name {
  font-size: 15px;
  color: var(--text-main);
  font-weight: 500;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
}

.review-product-price {
  display: flex;
  align-items: center;
  gap: 8px;
}

.review-product-price .price {
  color: var(--color-danger);
  font-weight: 600;
  font-size: 16px;
}

.review-product-price .quantity {
  color: var(--text-secondary);
  font-size: 14px;
}

.review-form {
  padding: 0 10px;
}

.review-form .el-rate {
  margin-top: 8px;
}

.intervention-order-info {
  margin-bottom: 20px;
}

.intervention-order-info .order-summary {
  display: flex;
  gap: 16px;
  padding: 16px;
  background: #f8faf5;
  border-radius: 8px;
  align-items: center;
}

.intervention-order-info .product-img {
  width: 60px;
  height: 60px;
  border-radius: 6px;
  overflow: hidden;
}

.intervention-order-info .product-info .product-name {
  font-size: 14px;
  color: var(--text-main);
  font-weight: 500;
  margin-bottom: 8px;
}

.intervention-order-info .product-info .order-amount {
  font-size: 14px;
  color: var(--color-danger);
}

.intervention-detail .detail-item {
  margin-bottom: 16px;
}

.intervention-detail .detail-item .label {
  color: var(--text-secondary);
  margin-right: 8px;
}

.intervention-detail .reject-reason {
  color: var(--color-danger);
}

.status-wrapper .intervention-rejected {
  background-color: #fef0f0;
  color: var(--color-danger);
}
</style> 