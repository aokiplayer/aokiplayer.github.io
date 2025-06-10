// カスタムメニュートグル機能
jQuery(document).ready(function() {
    // 年のメニューをクリックした時の動作
    jQuery('#sidebar .category-toggle').on('click', function(e) {
        e.preventDefault();
        
        var $this = jQuery(this);
        var $icon = $this.find('.category-icon');
        var $submenu = $this.parent().find('ul');
        
        // アイコンの回転とサブメニューの表示切り替え
        $icon.toggleClass('fa-angle-right fa-angle-down');
        $submenu.slideToggle(300);
        
        return false;
    });
});