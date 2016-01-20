"use strict";
(($)->
  Sidebar=(element, options)->
    this.options=options
    this.$body=$ document.body
    this.$element=$ element
#    sidebar是否显示
    this.isShown=false
#    是否忽略点击背景
    this.ignoreBackdropClick=false

#    Sidebar的默认值
  Sidebar.DEFAULTS={
    backdrop:true
    show:true
  }
  Sidebar.TRANSITION_DURATION = 300
  Sidebar.BACKDROP_TRANSITION_DURATION = 150
  Sidebar.prototype.toggle=(_relativeTarget)->
    return if this.isShown then this.hide() else this.show(_relativeTarget)

  Sidebar.prototype.show=(_relativeTarget)->
    that=this
    if this.isShown then return

    this.isShown=true
    this.$body.addClass("sidebar-open")
#    注册事件,监听"click.dismiss.sidebar"
    this.$element.on "click.dismiss.sidebar", "[data-dismiss='sidebar']", $.proxy this.hide, this
#    背景逻辑
    this.backdrop ()->
#      检测是否支持动画以及元素是否有fade类(这是代表用户希望使用动画)
      transition=$.support.transition && that.$element.hasClass "fade"
      if !that.$element.parent().length
        that.$element.appendTo that.$body

#      让Sidebar显示并且移动到上面
      that.$element.show().scrollTop 0
#      准备动画
      if transition
        that.$element[0].offsetWidth
      that.$element.addClass "in"
      .attr "aria-hidden", false

#      if transition
#

#      隐藏的方法
  Sidebar.prototype.hide=(e)->
    if e then e.preventDefault()
#      压根没有显示,所以直接返回就可以
    if !this.isShown
      return

    this.isShown=false
#    this.$body.removeClass "sidebar-open"
    this.$element.removeClass "in"
    .off "click.dismiss.sidebar"
#
    if $.support.transition and this.$element.hasClass "fade"
      this.$element.one "bsTransitionEnd", $.proxy this.hideSidebar, this
      .emulateTransitionEnd Sidebar.TRANSITION_DURATION
    else
      this.hideSidebar()
#
  Sidebar.prototype.hideSidebar=()->
    that=this
    this.$element.hide()
    this.backdrop ()->
      that.$body.removeClass "sidebar-open"

  Sidebar.prototype.removeBackdrop=()->
    if this.$backdrop
      this.$backdrop.remove()
      this.$backdrop=null
#  在backdrop里面处理具体的背景显示信息,callback是侧栏显示的逻辑
  Sidebar.prototype.backdrop=(callback)->
    that=this
#    是否包含fade样式
    animate=if this.$element.hasClass "fade" then "fade" else ""
#      如果正在侧栏正在显示并且需要背景
    if this.isShown && this.options.backdrop
#      doAnimate标记是否需要动画
      doAnimate = $.support.transition and animate
#      添加上背景div,并且设置样式,如果前面animate设置了fade,
#       也就是说用户希望有一个过度的动画效果,所以背景DIV也要加上过度的动画效果
      this.$backdrop=$ document.createElement "div"
      .addClass "sidebar-backdrop "+animate
      .appendTo this.$body

#      绑定事件click.dismiss.sidebar
      this.$element.on "click.dismiss.sidebar", $.proxy (e)->
#       bootstrap里面出现了这一句,我不是很明白
        if this.ignoreBackdropClick
          this.ignoreBackdropClick=false
          return

        if e.target!=e.currentTarget then return
        if this.options.backdrop == 'static'
          this.$element[0].focus()
        else this.hide()
      , this

#     准备动画
      if animate
        this.$backdrop[0].offsetWidth

      this.$backdrop.addClass "in"
#没有传入回调函数,直接返回
      if !callback
        return
      if doAnimate
        this.$backdrop
        .one "bsTransitionEnd", callback
        .emulateTransitionEnd Sidebar.BACKDROP_TRANSITION_DURATION
      else
        callback()
#    该条件用于隐藏侧栏
    else if !this.isShown and this.$backdrop
      this.$backdrop.removeClass "in"
      callbackRemove=()->
        that.removeBackdrop()
        if callback then callback()

#      检测动画,在动画完毕之后回调隐藏背景的函数
      if $.support.transition and this.$element.hasClass "fade"
        this.$backdrop
        .one "bsTransitionEnd", callbackRemove
        .emulateTransitionEnd Sidebar.BACKDROP_TRANSITION_DURATION
      else
        callbackRemove()
    else if callback
      callback()

  Plugin=(option, _relativeTarget)->
    this.each ()->
#      this代表的正是sidebar
      $this=$ this
#      缓存
      data=$this.data "sidebar"
      options=$.extend {}, Sidebar.DEFAULTS, $this.data(), typeof option=="object" and option

      if !data
        data=new Sidebar(this, options)
#        写入缓存
        $this.data "sidebar", data
      if typeof option=="string"
        data[option] _relativeTarget
      else if options.show
        data.show _relativeTarget

  $.fn.sidebar=Plugin
  $.fn.sidebar.Constructor=Sidebar
  $ document
  .on "click", "[data-toggle='sidebar']", (e)->
    $this=$ this
    $target=$ $this.attr "data-target"
    option=if $target.data "sidebar" then "toggle" else $.extend {}, $target.data(), $this.data()
    if $this.is "a" then e.preventDefault()
    Plugin.call $target, option, this
) window.jQuery