package com.typing.agora_wrapper.agora_wrapper.faceunity_plugin.modules

import com.faceunity.core.entity.FUBundleData
import com.faceunity.core.model.prop.Prop
import com.faceunity.core.model.prop.sticker.Sticker
import com.typing.agora_wrapper.agora_wrapper.faceunity_plugin.FaceunityKit
import io.flutter.plugin.common.MethodChannel

/**
 *
 * @author benyq
 * @date 11/10/2023
 *
 */
class FUStickerPlugin: BaseModulePlugin() {

    private val methods = mapOf(
        "selectSticker" to ::selectSticker,
        "removeSticker" to ::removeSticker
    )

    override fun methods(): Map<String, (Map<String, Any>, MethodChannel.Result) -> Any> = methods
    override fun tag(): String = "FUStickerPlugin"

    private var oldProp: Prop? = null

    fun enableSticker(enable: Boolean) {
        renderKit.propContainer.getAllProp().forEach {
            it.enable = enable
        }
    }

    private fun selectSticker(params: Map<String, Any>, result: MethodChannel.Result) {
        val name = params.getString("name") ?: return
        val sticker = Sticker(FUBundleData("sticker/${name}.bundle"))
        sticker.enable = FaceunityKit.isEffectsOn
        renderKit.propContainer.replaceProp(oldProp, sticker)
        oldProp = sticker
    }

    private fun removeSticker(params: Map<String, Any>, result: MethodChannel.Result) {
        renderKit.propContainer.removeAllProp()
    }

}