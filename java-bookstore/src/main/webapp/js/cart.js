// AJAX add to cart
function addToCart(bookId) {
    fetch(contextPath + '/cart/add', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'bookId=' + bookId
    })
    .then(res => res.json())
    .then(data => {
        var toast = document.getElementById('toast');
        if (data.success) {
            var cnt = document.querySelector('.cart-count');
                if (cnt) {
                    if (data.count > 0) cnt.textContent = data.count;
                    else cnt.remove();
                }
            toast.className = 'toast';
            toast.textContent = '✅ 已加入购物车 (共' + data.count + '件)';
        } else {
            toast.className = 'toast error';
            toast.textContent = '❌ ' + data.msg;
        }
        toast.style.display = 'block';
        setTimeout(function() { toast.style.display = 'none'; }, 2000);
    })
    .catch(err => {
        var toast = document.getElementById('toast');
        toast.className = 'toast error';
        toast.textContent = '❌ 操作失败';
        toast.style.display = 'block';
        setTimeout(function() { toast.style.display = 'none'; }, 2000);
    });
}
