# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

updateTransformationUpdateLink = ->
  ref = $('.update-transformation-data').prop('href')
  ref = ref.replace(/year_a=\d+/, 'year_a=' + $('#date_year_a').val())
  ref = ref.replace(/year_b=\d+/, 'year_b=' + $('#date_year_b').val())
  ref = ref.replace(/month_a=\d+/, 'month_a=' + $('#date_month_a').val())
  ref = ref.replace(/month_b=\d+/, 'month_b=' + $('#date_month_b').val())
  $('.update-transformation-data').prop('href', ref)
  return

$(document).on "page:change", ->
  $('.transformation-dates select').on 'change', updateTransformationUpdateLink
  return