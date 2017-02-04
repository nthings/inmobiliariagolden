$(document).ready(function() {
    $("form").submit(function(e) {

        var ref = $(this).find("[required]");

        $(ref).each(function(){
            if ( $(this).val() == '' ){
                alert("El campo no debe estar vacío.");

                $(this).focus();

                e.preventDefault();
                return false;
            }
        });  return true;
    });
    $('.number').keyup(function(event) {
      // skip for arrow keys
      if(event.which >= 37 && event.which <= 40) return;

      // format number
      this.value = this.value.replace(/[^0-9\.]/g, '')
                               .replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    });
});