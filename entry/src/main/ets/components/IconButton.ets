export interface IconButtonOptions {
    iconRes: PixelMap | ResourceStr | DrawableDescriptor,
    rotate?: number,
    iconColor?: ResourceColor,
    iconSize?: Size,
    buttonSize?: Size,
    buttonColor?: ResourceColor
}

@Component
export struct IconButton {
    @Require options?: IconButtonOptions

    build() {
        Button() {
            Image(this.options?.iconRes)
                .fillColor(this.options?.iconColor)
                .size({
                    width: this.options?.iconSize?.width ?? 24,
                    height: this.options?.iconSize?.height ?? 24
                })
                .rotate({
                    centerX: '50%',
                    centerY: '50%',
                    angle: this.options?.rotate ?? 0
                })
        }
        .type(ButtonType.Circle)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .backgroundColor(this.options?.buttonColor)
        .size({
            width: this.options?.buttonSize?.width ?? 36,
            height: this.options?.buttonSize?.height ?? 36
        })
    }
}