package com.rethinkos.flashnext_app

import java.io.IOException
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import javax.net.ssl.SSLException

enum class TransferPhase { CHECKSUM, CONNECTING, RECEIVING, RETRYING }
data class TransferStatus(val phase: TransferPhase, val attempt: Int=1, val host: String?=null) {
    val label: String get() = when(phase) {
        TransferPhase.CHECKSUM -> "正在读取安装包校验信息…"
        TransferPhase.CONNECTING -> if(host=="release-assets.githubusercontent.com" || host=="objects.githubusercontent.com") "正在连接安装包下载节点…" else "正在连接下载服务器…"
        TransferPhase.RECEIVING -> "正在下载安装包…"
        TransferPhase.RETRYING -> "下载连接中断，正在重试（$attempt/3）…"
    }
}
data class TransferPolicy(val attempts: Int=3, val retryDelayMillis: Long=1000, val timeoutMillis: Long=180_000) {
    init { require(attempts in 1..3 && retryDelayMillis>=0 && timeoutMillis>0) }
}
enum class UpdateResource(val label: String) { RELEASE("检查更新"), CHECKSUM("读取安装包校验信息"), APK("下载安装包") }
class UpdateTransportException(val resource: UpdateResource, val host: String, cause: IOException) : IOException(
    when(cause) {
        is SocketTimeoutException -> "${resource.label}超时（$host），请稍后重试或更换网络"
        is UnknownHostException -> "无法解析更新下载地址（$host），请检查网络"
        is SSLException -> "更新连接的证书验证失败（$host）"
        else -> "${resource.label}时连接中断（$host），请稍后重试或更换网络"
    },cause)
class UpdateHttpException(val status: Int) : IOException("更新下载失败（HTTP $status）")
fun retryableUpdateFailure(error: IOException): Boolean = when(error) {
    is UpdateHttpException -> error.status in listOf(408,500,502,503,504)
    is UpdateTransportException -> error.cause !is SSLException
    else -> error !is SSLException
}
fun Throwable.updateMessage(): String = when(this) {
    is UpdateTransportException, is UpdateHttpException -> message ?: "更新下载失败"
    else -> userMessage()
}
