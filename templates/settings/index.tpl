<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-compose" data-theme="a" data-dom-cache="false">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">

	<form id="frm{$uniqid}" method="post">
	<input type="hidden" name="c" value="m">
	<input type="hidden" name="a" value="saveSettings">
	<input type="hidden" name="_csrf_token" value="{$session.csrf_token}">
	
	<h3>Settings</h3>

	<fieldset data-role="controlgroup">
		<legend>{'preferences.account.mail.signature'|devblocks_translate}</legend>
		
 		<input type="radio" name="mobile_mail_signature_pos" id="mobile_mail_signature_pos-0" value="0" {if empty($worker_prefs.mobile_mail_signature_pos)}checked="checked"{/if}>
        <label for="mobile_mail_signature_pos-0">{'preferences.account.mail.signature.none'|devblocks_translate}</label>
		
 		<input type="radio" name="mobile_mail_signature_pos" id="mobile_mail_signature_pos-1" value="1" {if 1==$worker_prefs.mobile_mail_signature_pos}checked="checked"{/if}>
        <label for="mobile_mail_signature_pos-1">{'preferences.account.mail.signature.above'|devblocks_translate}</label>
		
 		<input type="radio" name="mobile_mail_signature_pos" id="mobile_mail_signature_pos-2" value="2" {if 2==$worker_prefs.mobile_mail_signature_pos}checked="checked"{/if}>
        <label for="mobile_mail_signature_pos-2">{'preferences.account.mail.signature.below'|devblocks_translate}</label>
	</fieldset>

	<button type="button" class="submit" data-theme="b">{'common.save_changes'|devblocks_translate|capitalize}</button>
	
	</form>
	
</div>

<script type="text/javascript">
$(document).one('pageinit', function() {
	var $frm = $('#frm{$uniqid}');

	$frm.find('button.submit').click(function() {
		$.mobile.loading('show');
		
		$.post(
			'{devblocks_url}ajax.php{/devblocks_url}',
			$frm.serialize(),
			function(json) {
				if(undefined == json.success || !json.success)
					return;
				
				$.mobile.loading('hide');
			}
		);
	});
});
</script>

</div><!-- /page -->

</body>
</html>

