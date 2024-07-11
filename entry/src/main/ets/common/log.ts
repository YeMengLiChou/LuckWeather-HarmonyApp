const prefix = "\n    -->"

function info(tag: string, ...data: any[]) {
    const msg = [tag, ...data].join(prefix)
    console.info(msg)
}


function log(tag: string, ...data: any[]) {
    const msg = [tag, ...data].join(prefix)
    console.log(msg)
}


function error(tag: string, ...data: any[]) {
    const msg = [tag, ...data].join(prefix)
    console.error(msg)
}

export default {
    info,
    log,
    error
}