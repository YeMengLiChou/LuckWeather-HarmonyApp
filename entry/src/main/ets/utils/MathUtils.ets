export function max<T>(action: (item: T) => number, ...values: T[]) {
    let res = Number.MIN_VALUE
    values.forEach((item) => {
        res = Math.max(res, action(item))
    });
    return res
}


export function min<T>(action: (item: T) => number, ...values: T[]) {
    let res = Number.MAX_VALUE
    values.forEach((item) => {
        res = Math.min(res, action(item))
    })
    return res
}

