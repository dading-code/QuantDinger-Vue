<template>
  <a-modal
    :visible="visible"
    title="API Key 获取成功"
    :footer="null"
    @cancel="handleClose"
    width="600px"
  >
    <a-alert
      type="warning"
      message="️ 重要提示：API Key只在创建时显示一次，请妥善保存！"
      show-icon
      style="margin-bottom: 16px"
    />

    <a-form layout="vertical">
      <a-form-item label="API Key">
        <a-input-group compact>
          <a-input
            :value="apiKey"
            readonly
            style="width: calc(100% - 100px)"
          />
          <a-button @click="copyApiKey">复制</a-button>
        </a-input-group>
      </a-form-item>

      <a-divider />

      <h3>💡 使用方法</h3>
      <a-alert
        type="info"
        message="将上方API Key粘贴到本地客户端的「API 密钥」输入框中"
        show-icon
        style="margin-bottom: 16px"
      />
      <a-steps :current="currentStep" direction="vertical" size="small">
        <a-step title="复制 API Key">
          <p>点击上方「复制」按钮复制密钥</p>
        </a-step>
        <a-step title="粘贴到客户端">
          <p><strong>1.</strong> 运行 QuantDinger Local Client</p>
          <p><strong>2.</strong> 在「API 密钥」输入框中粘贴密钥</p>
          <p><strong>3.</strong> 点击「 保存配置」</p>
          <p><strong>4.</strong> 点击「▶ 启动」开始接收信号</p>
        </a-step>
        <a-step title="开始自动交易">
          <p>✅ 客户端将自动连接云端WebSocket</p>
          <p>✅ 实时接收属于您的交易信号</p>
          <p>✅ 在本地执行MT5/IBKR交易</p>
        </a-step>
      </a-steps>

      <a-divider />

      <a-alert
        type="success"
        message="✅ 提示：您可以随时在网页端停用或删除此API Key"
        show-icon
      />
    </a-form>
  </a-modal>
</template>

<script>
export default {
  name: 'ApiKeyModal',
  data () {
    return {
      visible: false,
      apiKey: '',
      currentStep: 0
    }
  },
  methods: {
    show (apiKey) {
      this.apiKey = apiKey
      this.visible = true
      this.currentStep = 0
    },
    handleClose () {
      this.visible = false
      this.$emit('close')
    },
    copyApiKey () {
      navigator.clipboard.writeText(this.apiKey).then(() => {
        this.$message.success('API Key已复制到剪贴板')
      }).catch(() => {
        this.$message.error('复制失败')
      })
    }
  }
}
</script>

<style scoped>
code {
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 3px;
}
</style>
