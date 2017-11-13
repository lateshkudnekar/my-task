var data = [];
jQuery(document).ready(function(){

	var productCustomization = $('.cd-customization'),
		  cart = $('.cd-cart');


  $.fn.addToCart = function(element, title, id, image) {
    var button = $(element);
    var product_element = button.parent();
    var product = {
      title: title,
      id: id,
      image: image
    }

    product_element.addClass('added');
    data.push(product);
    updateCart(cart);
    $('.contact-link').hide();
    setTimeout(function() {
      product_element.find('.text').fadeOut(500);
    }, 1500);
  }

  $('#selected-products').on('click', 'li', function(e) {
    removeFromCart($(e.currentTarget).data('product-id'), cart);
  })
});

function updateCart(cart) {
	if (data.length>0) {
	  //show counter if this is the first item added to the cart
	  ( !cart.hasClass('items-added') ) && cart.addClass('items-added');
	} else {
		cart.removeClass('items-added');
		$('.contact-link').show();
	}
  var cartItems = cart.find('span.int');
  cartItems.text(data.length);

  setSelectedProducts();
}

function setSelectedProducts() {
  var html = "";
  var selectedProducts = "";

  data.forEach(function(item) {
    var product = "<li data-product-id='" + item.id + "'>" + item.title + " <i class='fa fa-times'></i></li>";
    html += product;
    selectedProducts += item.title + ",";
  });
	if ( selectedProducts.length ){
		$('#selected-products').show().find('ul').html(html);
		$('#selected-products').find('input').val(selectedProducts);
	} else {
		$('#selected-products').hide();
	}
}

function removeFromCart(id, cart) {
  $('#product-item-' + id).removeClass('added');

  $.each(data, function(i){
      if(data[i].id === id) {
          data.splice(i,1);
          return false;
      }
  });

	updateCart(cart);
}

function checkCartAfterLoad() {
  $.each(data, function(i){
    $('#product-item-' + data[i].id).addClass("added");
    setTimeout(function() {
      $('#product-item-' + data[i].id).find('.text').fadeOut(500);
    }, 1500);
  });

}
