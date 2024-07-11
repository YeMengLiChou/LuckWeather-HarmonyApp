/**
 * 获取周x文本
 * */
export function getWeekendText(time: number | string) {
    const date = new Date(time)
    const now = new Date()
    if (date.getDate() == now.getDate()) {
        return '今天'
    } else if (date.getDate() == now.getDate() + 1) {
        return '明天'
    }
    const day = date.getDay()
    switch (day) {
        case 0:
            return '周日';
        case 1:
            return '周一';
        case 2:
            return '周二';
        case 3:
            return '周三';
        case 4:
            return '周四';
        case 5:
            return '周五';
        case 6:
            return '周六';
    }
    return ''
}
