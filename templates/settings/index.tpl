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
	
	<h3>Settings</h3>
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

