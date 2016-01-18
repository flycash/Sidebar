"use strict";
(($)->
  Sidebar=(element, options)->
    this.option=options
    this.$body=$ document.body
    this.$element=$ element
    this.isShown=false

#    Sidebar的默认值
  Sidebar.DEFAULTS={

  }

  Sidebar.prototype.toggle=(_relativeTarget)->
    return if this.isShown then this.hide() else this.show(_relativeTarget)

  Sidebar.prototype.show=(_relativeTarget)->
    that=this
    if this.isShown then 0

    this.isShown=true

  console.log "end"
) window.jQuery