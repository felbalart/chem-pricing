
function toggleFreightSubtypeInputs() {
  var f_type = $('#quote_freight_base_type_input input:checked').val();
  $('.bulk-subtype-input').parent().toggle(f_type === 'bulk');
  $('.packed-subtype-input').parent().toggle(f_type === 'packed');
  $('.special-subtype-input').parent().toggle(f_type === 'special');
}

function toggleFreightPadraoInput() {
  var freightPadrao = $('#quote_freight_padrao').is(":checked");
  $(".freight-show-if-padrao").closest('li.input').toggle(freightPadrao);
  $("#quote_unit_freight_input").toggle(!freightPadrao);
  if(freightPadrao) {
    toggleFreightSubtypeInputs();
    toggleVehicleInput();
  }
}

function toggleVehicleInput() {
  var f_type = $('#quote_freight_base_type_input input:checked').val();
  var s2_subtype = $('.' + f_type + '-subtype-input').select2('data');
  var f_subtype;
  if(s2_subtype !== null) {
    f_subtype = s2_subtype['id'];
  }
  var show_vehicle = ((f_type === 'bulk' && (f_subtype === 'normal' || f_subtype === 'product')) || (f_type === 'special'));
  $('#quote_vehicle_input').toggle(show_vehicle);
}

function togglePriceMarkupInput() {
  var priceFixed = $('#quote_fixed_price_true:checked').val() !== undefined;
  $('#quote_unit_price').prop('disabled', !priceFixed).toggleClass('disabled-input', !priceFixed);
  $('#quote_markup').prop('disabled', priceFixed).toggleClass('disabled-input', priceFixed);
}

function fetchData() {
  var distCenterId = ($('#quote_dist_center_id').select2('data') || {}).id;
  var productId = ($('#quote_product_id').select2('data') || {}).id;
  var customerId = ($('#quote_customer_id').select2('data') || {}).id;
  var url = '/quotes/fetch_data.json';
  $.ajax({
    type: "GET",
    dataType: "script",
    url: url,
    data: {
      dist_center_id: distCenterId,
      product_id: productId,
      customer_id: customerId
    },
    complete: function(data, textStatus, jqXHR){
      if((data === undefined) || (data.responseText === undefined)) { return; }
      var respObj = JSON.parse(data.responseText) || {};
      processMarkup(respObj.table_value);
      processUnit(respObj.unit);
      processCurrency(respObj.currency);
    }
  });
}

function processMarkup(tableValue) {
  if(tableValue !== undefined) {
    if(tableValue !== undefined && tableValue !== null && !isNaN(tableValue)) {
      tableValue = 100 * Number(tableValue);
    }
    $('#quote_markup').val(tableValue)
  }
}

function processUnit(unit) {
  if(unit !== 'kg' && unit !== 'lt') return;
  $('#quote_unit_' + unit).prop("checked",true);
}

function processCurrency(currency) {
  if(currency !== 'brl' && currency !== 'usd' && currency !== 'eur') return;
  $('#quote_currency_' + currency).prop("checked",true);
}

function fetchFinancialCost() {
  var paymentTerm = $('#quote_payment_term').val();
  var url = '/quotes/fetch_financial_cost.json';
  $.ajax({
    type: "GET",
    dataType: "script",
    url: url,
    data: {
      payment_term: paymentTerm
    },
    complete: function(data, textStatus, jqXHR){
      if((data === undefined) || (data.responseText === undefined)) { return; }
      var respObj = JSON.parse(data.responseText) || {};
      var financialCostValue = respObj.value;
      $('#financial-cost-percentage').val(financialCostValue);
    }
  });
}

function fetchIcms() {
  var distCenterId = ($('#quote_dist_center_id').select2('data') || {}).id;
  var customerId = ($('#quote_customer_id').select2('data') || {}).id;
  var cityId = ($('#quote_city_id').select2('data') || {}).id;
  var productId = ($('#quote_product_id').select2('data') || {}).id;
  var redispatchSelected = $('#quote_freight_condition_redispatch').is(':checked');
  var originPresent = distCenterId !== undefined;
  var destPresent;
  if(redispatchSelected || customerId === undefined) {
    destPresent = cityId !== undefined;
  } else {
    destPresent = customerId !== undefined;
  }
  if(!originPresent || !destPresent) {
    return false;
  } else {
      var url = '/quotes/fetch_icms.json';
      $.ajax({
        type: "GET",
        dataType: "script",
        url: url,
        data: {
          dist_center_id: distCenterId,
          customer_id: customerId,
          redispatch: redispatchSelected,
          city_id: cityId,
          product_id: productId
        },
        complete: function(data, textStatus, jqXHR){
          if((data === undefined) || (data.responseText === undefined)) { return; }
          var respObj = JSON.parse(data.responseText);

          var origin = (respObj || {}).origin;
          var destination = (respObj || {}).destination;
          updateOriginDestination(origin, destination);

          var icmsValue = (respObj || {}).icms;
          var icmsPadrao = $('#quote_icms_padrao').is(":checked");
          if(icmsPadrao) {
            if(icmsValue !== undefined && icmsValue !== null && !isNaN(icmsValue)) {
              icmsValue = 100 * Number(icmsValue);
            }
            $('#quote_icms').val(icmsValue)
          }
        }
      });
      return true;
  }
}

function toggleIcms() {
  var icmsPadrao = $('#quote_icms_padrao').is(":checked");
  $('#quote_icms').prop('disabled', icmsPadrao).toggleClass('disabled-input', icmsPadrao);
  var result = fetchIcms();
  if(icmsPadrao && !result) {
    $('#quote_icms').val(null);
  }
  if(!result) {
    clearOriginDestination();
  }
}

function togglePisConfins() {
  var pisConfinsPadrao = $('#quote_pis_confins_padrao').is(":checked");
  $('#quote_pis_confins').prop('disabled', pisConfinsPadrao).toggleClass('disabled-input', pisConfinsPadrao)
}

function toggleCityInput() {
  var hasCustomer = !!$('#quote_customer_id').select2('data');
  var redispatchSelected = $('#quote_freight_condition_redispatch').is(':checked');
  var enableCity = !hasCustomer || redispatchSelected;
  $('#quote_city_id').prop('disabled', !enableCity);
}

function toggleFreightInputs() {
  var fobSelected = $('#quote_freight_condition_fob').is(':checked');
  $('#quote_freight_subtype, #quote_vehicle_id, .freight-fieldset input:radio').prop('disabled', fobSelected);
  $(".freight-fieldset").toggleClass('disabled-input', fobSelected)
}

function fakeSimulatorSelect() {
  $('li#quotes').removeClass('current');
  $('li#simulator').addClass('current');
}

function updateOriginDestination(origin, destination) {
  var orDestTag;
  if(origin && destination) {
    orDestTag = '[' + origin + '->' + destination + ']';
  } else {
    orDestTag = '';
  }
  $('.taxes-fields > .inputs > legend > span').html('Impostos   ' + orDestTag);
  $('.freight-fieldset > legend > span').html('Frete   ' + orDestTag);
}

function clearOriginDestination() {
  updateOriginDestination(null, null);
}

function clearProductInfoBox() {
  var simulateMsg = '<p class="simulate-msg">Primeiro você tem que simular uma cotação para ver esta informaçao</p>';
  $('.product-info-section .panel_contents').html(simulateMsg);
  var clearedTitle = 'INFORMAÇAO DE ADICIONAL DE PRODUTO';
  $('.product-info-section h3').html(clearedTitle);

}

function convertPercentageFields(toPerc) {
  var factor = toPerc ? 100 : 0.01;
  var fields = ['#quote_markup', '#quote_icms', '#quote_pis_confins'];
  for(var i = 0; i < 3; i++) {
    var input = $(fields[i]);
    var originalValue = Number(input.val());
    if(originalValue !== 0 && !isNaN(originalValue)) {
      var newValue = originalValue * factor;
      input.val(newValue);
    }
  }
}

$(function () {
  $('.base-field-input').change(function () {
    fetchData();
    var icmsPadrao = $('#quote_icms_padrao').is(":checked");
    if(icmsPadrao) fetchIcms();
  });

  $('#quote_product_id').change(function () {
    clearProductInfoBox();
  });

  $('#quote_customer_id, #quote_freight_condition_input').change(function () {
    toggleCityInput();
    toggleFreightInputs();
    toggleIcms();
  });

  $('#quote_dist_center_id, #quote_city_id').change(function () {
    toggleIcms();
  });

  $('#quote_fixed_price_true, #quote_fixed_price_false').change(function () {
    togglePriceMarkupInput();
  });

  $('#quote_freight_base_type_bulk, #quote_freight_base_type_packed, #quote_freight_base_type_special').change(function () {
    toggleFreightSubtypeInputs();
    toggleVehicleInput();
  });

  $('#quote_freight_padrao').change(function () {
    toggleFreightPadraoInput();
  });

  $('#quote_icms_padrao').change(function () {
    toggleIcms();
  });

  $('#quote_pis_confins_padrao').change(function () {
    togglePisConfins();
  });

  $('[id="quote_freight_subtype_input"]').change(function () {
    toggleVehicleInput();
  });

  $('#quote_payment_term').change(function () {
    fetchFinancialCost();
  });

  $('form.quote').submit(function () {
    var f_type = $('#quote_freight_base_type_input input:checked').val();
    $('#quote_freight_subtype:not(.' + f_type + '-subtype-input)').remove();
    convertPercentageFields(false);
    var freightPadrao = $('#quote_freight_padrao').is(":checked");
    (freightPadrao ? $('#quote_unit_freight') : $(".freight-show-if-padrao")).remove();
    return true;
  });

  toggleFreightSubtypeInputs();
  toggleFreightPadraoInput();
  toggleVehicleInput();
  togglePriceMarkupInput();
  toggleCityInput();
  togglePisConfins();
  toggleIcms();
  convertPercentageFields(true);
  if($('#page_title').html() === 'Simulador de Preço') {
    fakeSimulatorSelect();
  }
  // Append sub-label to this row in result's table
  $('.row-taxed_charged_freight th').append(
    '<p style="font-size: 10px; font-weight: normal; text-transform: none; white-space: nowrap">(Com impostos e encargos)</p>'
  )
});
