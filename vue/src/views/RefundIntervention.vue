<template>
  <div class="refund-intervention">
    <div class="page-header">
      <h2>交易纠纷</h2>
      <el-tag type="info">共 {{ total }} 条申请</el-tag>
    </div>

    <el-card class="operation-area" shadow="hover">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="处理状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="待处理" :value="0"></el-option>
            <el-option label="已通过" :value="1"></el-option>
            <el-option label="已拒绝" :value="2"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button size="medium" plain type="primary" @click="handleSearch">查询</el-button>
          <el-button size="medium" plain @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <div class="statistics-cards">
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card shadow="hover" class="stat-card pending">
            <div class="stat-content">
              <div class="stat-left">
                <div class="stat-icon"><i class="el-icon-warning"></i></div>
                <div class="stat-title">待处理</div>
              </div>
              <div class="stat-value">{{ getCountByStatus(0) }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="stat-card approved">
            <div class="stat-content">
              <div class="stat-left">
                <div class="stat-icon"><i class="el-icon-circle-check"></i></div>
                <div class="stat-title">已通过</div>
              </div>
              <div class="stat-value">{{ getCountByStatus(1) }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="stat-card rejected">
            <div class="stat-content">
              <div class="stat-left">
                <div class="stat-icon"><i class="el-icon-circle-close"></i></div>
                <div class="stat-title">已拒绝</div>
              </div>
              <div class="stat-value">{{ getCountByStatus(2) }}</div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <el-card class="table-card" shadow="hover">
      <el-table :data="list" border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="申请ID" width="80"></el-table-column>
        <el-table-column label="商品信息" min-width="200">
          <template slot-scope="scope">
            <div class="product-info">
              <div class="product-name">{{ scope.row.productName }}</div>
              <div class="product-price">¥{{ scope.row.orderPrice }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="申请人" width="120">
          <template slot-scope="scope">
            <div>{{ scope.row.user?.name || scope.row.user?.username }}</div>
          </template>
        </el-table-column>
        <el-table-column label="商家" width="120">
          <template slot-scope="scope">
            <div>{{ scope.row.merchant?.name || scope.row.merchant?.username }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="reason" label="申请原因" min-width="200" show-overflow-tooltip></el-table-column>
        <el-table-column label="状态" width="100">
          <template slot-scope="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="申请时间" width="160">
          <template slot-scope="scope">
            {{ formatTime(scope.row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template slot-scope="scope">
            <el-button type="text" size="small" @click="handleDetail(scope.row)">详情</el-button>
            <el-button 
              v-if="scope.row.status === 0" 
              type="text" 
              size="small" 
              @click="handleProcess(scope.row)">处理</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-show="total > 0"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="currentPage"
        :page-sizes="[10, 20, 50]"
        :page-size="pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total">
      </el-pagination>
    </el-card>

    <el-dialog title="申请详情" :visible.sync="detailDialogVisible" width="600px">
      <div v-if="currentItem" class="detail-content">
        <div class="detail-section">
          <h4>订单信息</h4>
          <div class="detail-item">
            <span class="label">订单ID：</span>
            <span>{{ currentItem.orderId }}</span>
          </div>
          <div class="detail-item">
            <span class="label">商品名称：</span>
            <span>{{ currentItem.productName }}</span>
          </div>
          <div class="detail-item">
            <span class="label">订单金额：</span>
            <span class="price">¥{{ currentItem.orderPrice }}</span>
          </div>
        </div>
        <div class="detail-section">
          <h4>申请信息</h4>
          <div class="detail-item">
            <span class="label">申请人：</span>
            <span>{{ currentItem.user?.name || currentItem.user?.username }}</span>
          </div>
          <div class="detail-item">
            <span class="label">商家：</span>
            <span>{{ currentItem.merchant?.name || currentItem.merchant?.username }}</span>
          </div>
          <div class="detail-item">
            <span class="label">申请原因：</span>
            <span>{{ currentItem.reason }}</span>
          </div>
          <div class="detail-item" v-if="currentItem.images">
            <span class="label">图片证据：</span>
            <div class="image-list">
              <el-image
                v-for="(img, index) in parseImages(currentItem.images)"
                :key="index"
                :src="img.startsWith('http') ? img : `/api${img}`"
                :preview-src-list="parseImages(currentItem.images).map(i => i.startsWith('http') ? i : `/api${i}`)"
                fit="cover"
                class="evidence-image">
              </el-image>
            </div>
          </div>
          <div class="detail-item">
            <span class="label">申请时间：</span>
            <span>{{ formatTime(currentItem.createdAt) }}</span>
          </div>
        </div>
        <div class="detail-section" v-if="currentItem.status !== 0">
          <h4>处理结果</h4>
          <div class="detail-item">
            <span class="label">处理状态：</span>
            <el-tag :type="getStatusType(currentItem.status)">
              {{ getStatusText(currentItem.status) }}
            </el-tag>
          </div>
          <div class="detail-item">
            <span class="label">处理人：</span>
            <span>{{ currentItem.admin?.name || currentItem.admin?.username }}</span>
          </div>
          <div class="detail-item" v-if="currentItem.adminReply">
            <span class="label">处理意见：</span>
            <span>{{ currentItem.adminReply }}</span>
          </div>
        </div>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </div>
    </el-dialog>

    <el-dialog title="处理申请" :visible.sync="processDialogVisible" width="500px">
      <div v-if="currentItem" class="process-content">
        <div class="process-info">
          <p><strong>订单ID：</strong>{{ currentItem.orderId }}</p>
          <p><strong>商品名称：</strong>{{ currentItem.productName }}</p>
          <p><strong>订单金额：</strong><span class="price">¥{{ currentItem.orderPrice }}</span></p>
          <p><strong>申请原因：</strong>{{ currentItem.reason }}</p>
        </div>
        <el-form :model="processForm" :rules="processRules" ref="processForm" label-width="100px">
          <el-form-item label="处理结果" prop="status">
            <el-radio-group v-model="processForm.status">
              <el-radio :label="1">同意退款</el-radio>
              <el-radio :label="2">拒绝退款</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="处理意见" prop="adminReply">
            <el-input type="textarea" v-model="processForm.adminReply" :rows="4" placeholder="请填写处理意见"></el-input>
          </el-form-item>
        </el-form>
      </div>
      <div slot="footer" class="dialog-footer">
        <el-button @click="processDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitProcess" :loading="processLoading">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import Request from '@/utils/request'
import { formatTime } from '@/utils/time'

export default {
  name: 'RefundIntervention',
  data() {
    return {
      loading: false,
      list: [],
      total: 0,
      currentPage: 1,
      pageSize: 10,
      searchForm: {
        status: null
      },
      detailDialogVisible: false,
      processDialogVisible: false,
      currentItem: null,
      processForm: {
        status: 1,
        adminReply: ''
      },
      processRules: {
        status: [
          { required: true, message: '请选择处理结果', trigger: 'change' }
        ],
        adminReply: [
          { required: true, message: '请填写处理意见', trigger: 'blur' }
        ]
      },
      processLoading: false
    }
  },
  created() {
    this.getList()
  },
  methods: {
    formatTime,
    async getList() {
      this.loading = true
      try {
        const params = {
          currentPage: this.currentPage,
          size: this.pageSize
        }
        if (this.searchForm.status !== null && this.searchForm.status !== '') {
          params.status = this.searchForm.status
        }
        const res = await Request.get('/refund-intervention/list', { params })
        if (res.code === '0') {
          this.list = res.data.records || []
          this.total = res.data.total || 0
        }
      } catch (error) {
        console.error('获取列表失败:', error)
        this.$message.error('获取列表失败')
      } finally {
        this.loading = false
      }
    },
    handleSearch() {
      this.currentPage = 1
      this.getList()
    },
    resetSearch() {
      this.searchForm.status = null
      this.currentPage = 1
      this.getList()
    },
    handleSizeChange(val) {
      this.pageSize = val
      this.getList()
    },
    handleCurrentChange(val) {
      this.currentPage = val
      this.getList()
    },
    getCountByStatus(status) {
      return this.list.filter(item => item.status === status).length
    },
    getStatusText(status) {
      const map = {
        0: '待处理',
        1: '已通过',
        2: '已拒绝'
      }
      return map[status] || '未知'
    },
    getStatusType(status) {
      const map = {
        0: 'warning',
        1: 'success',
        2: 'danger'
      }
      return map[status] || 'info'
    },
    parseImages(images) {
      if (!images) return []
      try {
        return JSON.parse(images)
      } catch {
        return []
      }
    },
    handleDetail(row) {
      this.currentItem = row
      this.detailDialogVisible = true
    },
    handleProcess(row) {
      this.currentItem = row
      this.processForm = {
        status: 1,
        adminReply: ''
      }
      this.processDialogVisible = true
    },
    async submitProcess() {
      try {
        await this.$refs.processForm.validate()
        this.processLoading = true
        
        const user = JSON.parse(localStorage.getItem('backUser') || '{}')
        if (!user.id) {
          this.$message.error('获取用户信息失败，请重新登录')
          return
        }
        const res = await Request.put('/refund-intervention/handle', null, {
          params: {
            id: this.currentItem.id,
            status: this.processForm.status,
            adminId: user.id,
            adminReply: this.processForm.adminReply
          }
        })
        
        if (res.code === '0') {
          this.$message.success('处理成功')
          this.processDialogVisible = false
          this.getList()
        } else {
          this.$message.error(res.msg || '处理失败')
        }
      } catch (error) {
        console.error('处理失败:', error)
      } finally {
        this.processLoading = false
      }
    }
  }
}
</script>

<style scoped>
.refund-intervention {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 20px;
  color: var(--text-main);
}

.operation-area {
  margin-bottom: 20px;
}

.statistics-cards {
  margin-bottom: 20px;
}

.stat-card {
  border-radius: 8px;
}

.stat-card.pending .stat-icon {
  background: #fdf6ec;
  color: #e6a23c;
}

.stat-card.approved .stat-icon {
  background: #f0f9eb;
  color: var(--color-primary);
}

.stat-card.rejected .stat-icon {
  background: #fef0f0;
  color: var(--color-danger);
}

.stat-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-title {
  font-size: 14px;
  color: var(--text-secondary);
}

.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: var(--text-main);
}

.table-card {
  margin-bottom: 20px;
}

.product-info .product-name {
  font-size: 14px;
  color: var(--text-main);
  margin-bottom: 4px;
}

.product-info .product-price {
  font-size: 14px;
  color: var(--color-danger);
}

.detail-content {
  padding: 10px 0;
}

.detail-section {
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border-color-light);
}

.detail-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.detail-section h4 {
  margin: 0 0 16px 0;
  font-size: 16px;
  color: var(--text-main);
}

.detail-item {
  display: flex;
  margin-bottom: 12px;
  line-height: 1.6;
}

.detail-item .label {
  width: 80px;
  color: var(--text-secondary);
  flex-shrink: 0;
}

.detail-item .price {
  color: var(--color-danger);
  font-weight: 600;
}

.image-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.evidence-image {
  width: 80px;
  height: 80px;
  border-radius: 4px;
}

.process-content .process-info {
  background: #f8f8f8;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.process-content .process-info p {
  margin: 8px 0;
}

.process-content .price {
  color: var(--color-danger);
  font-weight: 600;
}

.el-pagination {
  margin-top: 20px;
  text-align: right;
}
</style>
