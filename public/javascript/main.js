var clicked = false
      $('#searchbutton').click(function(e){
        e.preventDefault();
        $('.container').removeAttr('id')

        if(clicked===false){
          clicked = true
          $(".loading_div").fadeIn(2000);
          $.get('/search',$('#gimmesongs').serialize(),function(response){
            $(".loading_div").fadeOut(1000);
            $('.container').html(response).removeAttr('id')
          })
        }
      })
$('.leftBar').hover(function(){
  $(this).stop().animate({left: "0em"},'fast');
}, function(){
  $(this).stop().animate({left: "-13em"},1000);
})