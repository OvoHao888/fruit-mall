<script setup>
import '../assets/iconfont.css';

</script>
<template>
    <div class="aside-container">
        <el-scrollbar class="menu-scrollbar" :native="false">
            <el-menu
                :default-active="$route.path"
                class="el-menu-vertical"
                router
                :collapse-transition="false"
                background-color="#fff"
                text-color="#606266">

                <div v-for="item in userMenuList" :key="item.id">
                    <div v-if="item.path">
                        <div v-if="!item.pid">
                            <el-menu-item :index="item.path">
                                <i :class="item.icon"></i>
                                <span>{{ item.name }}</span>
                            </el-menu-item>
                        </div>
                    </div>
                    <div v-else>
                        <el-submenu :index="item.id + ''">
                            <template slot="title">
                                <i :class="item.icon"></i>
                                <span>{{ item.name }}</span>
                            </template>
                            <div v-for="subItem in item.children" :key="subItem.id">
                                <el-menu-item :index="subItem.path">
                                    <i :class="subItem.icon"></i>
                                    <span>{{ subItem.name }}</span>
                                </el-menu-item>
                            </div>
                        </el-submenu>
                    </div>
                </div>
            </el-menu>
        </el-scrollbar>
    </div>
</template>

<script>
import {setRoutes} from "@/router";
import Request from '../utils/request.js'
export default {
    name: 'Aside',
    components: {},
    // 用户信息
    userInfo: {},
    created() {
        let userMenuListStr = localStorage.getItem("userMenuList")
        this.userMenuList = userMenuListStr ? JSON.parse(userMenuListStr) : [];
        this.userInfo = localStorage.getItem("backUser") ? JSON.parse(localStorage.getItem("backUser")) : {};
        console.log("userMenuList:" + userMenuListStr);
    },
    data() {
        return {
          
            userMenuList: [
                {
                    name: 'Dashboard',
                    path: 'dashboard',
                    icon: 'el-icon-menu'
                },
                {
                    name: 'Reports',
                    path: 'reports',
                    icon: 'el-icon-document',
                    children: [
                        {
                            name: 'Report 1',
                            path: 'report1',
                            icon: 'el-icon-document'
                        },
                        {
                            name: 'Report 2',
                            path: 'report2',
                            icon: 'el-icon-document'
                        }
                    ]
                },
                // 更多静态菜单项...
            ],
            user: {},
            path: this.$route.path
        }
    },
    methods: {
        printMenu(menu) {
            console.log("Submenu:" + menu)
        },
        refreshMenu(){
            Request.get("/menu/getMenuTree/"+this.userInfo.id).then(response => {
                if (response.code === '0') {
                    localStorage.setItem("userMenuList", JSON.stringify(response.data))
                    setRoutes();
         
                } else {
                    this.$message({
                        type: 'error',
                        message: response.msg
                    })
                }
            })
        }
    }
}
</script>

<style scoped>
.aside-container {
    height: 100%;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    padding-top: 8px;
    width: 100%; /* 确保宽度占满侧边栏 */
}

.menu-scrollbar {
    height: 100%;
    width: 100%;
}

/* 隐藏滚动条但保留滚动功能 */
.menu-scrollbar >>> .el-scrollbar__bar {
    opacity: 0 !important;
}

.menu-scrollbar >>> .el-scrollbar__wrap {
    overflow-x: hidden;
}

.el-menu {
    border-right: none;
    padding: 12px;
    width: 100%;
    box-sizing: border-box;
}

.el-menu-item {
    height: 50px;
    line-height: 50px;
    border-radius: 8px;
    margin-bottom: 4px;
    color: var(--text-regular);
    font-size: 16px;
    text-align: left;
    padding: 0 20px !important;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    
    &:hover {
        color: var(--color-primary);
        background-color: var(--color-primary-light) !important;
    }
    
    &.is-active {
        color: var(--color-primary);
        background-color: var(--color-primary-light) !important;
        font-weight: 600;
    }
}

.el-submenu ::v-deep .el-submenu__title {
    height: 50px;
    line-height: 50px;
    border-radius: 8px;
    color: var(--text-regular);
    font-size: 16px;
    text-align: left;
    padding: 0 20px !important;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    
    &:hover {
        color: var(--color-primary);
        background-color: var(--color-primary-light) !important;
    }
}

.el-submenu ::v-deep .el-menu--inline {
    padding-left: 0;
    
    .el-menu-item {
        height: 45px;
        line-height: 45px;
        padding-left: 48px !important;
        background-color: transparent;
        
        &:hover {
            color: var(--color-primary);
            background-color: var(--color-primary-light) !important;
        }
        
        &.is-active {
            color: var(--color-primary);
            background-color: var(--color-primary-light) !important;
            font-weight: 600;
        }
    }
}

/* 图标样式 */
.el-menu-item [class^="el-icon-"],
.el-submenu [class^="el-icon-"] {
    font-size: 18px;
    margin-right: 12px;
    color: var(--text-secondary);
    vertical-align: middle;
}

.el-menu-item.is-active [class^="el-icon-"],
.el-submenu.is-active [class^="el-icon-"] {
    color: var(--color-primary);
}

.el-menu-item span,
.el-submenu ::v-deep .el-submenu__title span {
    display: inline-block;
    vertical-align: middle;
}
</style>