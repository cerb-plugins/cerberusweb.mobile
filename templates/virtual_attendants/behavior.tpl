<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-va-behavior" data-theme="c">

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<a data-role="button" data-direction="reverse" data-rel="back" data-icon="arrow-l" data-iconpos="left" class="ui-btn-left">Back</a>
	<h1>Cerb Mobile</h1>
</div>

<div data-role="content">
	<a href="{devblocks_url}c=m&p=va&id={$va->id}{/devblocks_url}" data-role="button">{$va->name}</a>

	<form id="form-cerb-va-behavior-run" action="javascript:;" method="post" data-ajax="false" onsubmit="return false;">
	<input type="hidden" name="behavior_id" value="{$behavior->id}">

	<h3 style="margin:20px 0px 0px 0px;">{$behavior->title}</h3>
	
	{* Public variables *}
	{if is_array($behavior->variables)}
	{foreach from=$behavior->variables item=var key=var_key}
		{if !$var.is_private}
		
		<div data-role="fieldcontain">
			<label for="{$var_key}"> {$var.label}</label> 
			
			{if $var.type == Model_CustomField::TYPE_SINGLE_LINE}
				{if $var.params.widget == 'multiple'}
				<textarea name="{$var_key}" id="{$var_key}" placeholder=""></textarea>
				{else}
				<input name="{$var_key}" id="{$var_key}" placeholder="" value="" type="text">
				{/if}
			{elseif $var.type == Model_CustomField::TYPE_NUMBER}
				<input name="{$var_key}" id="{$var_key}" placeholder="" value="" type="number">
			{elseif $var.type == Model_CustomField::TYPE_DATE}
				<input name="{$var_key}" id="{$var_key}" placeholder="" value="" type="text">
			{elseif $var.type == Model_CustomField::TYPE_DROPDOWN}
				<select name="{$var_key}" id="{$var_key}">
					{$options = DevblocksPlatform::parseCrlfString($var.params.options, true)}
					{if is_array($options)}
					{foreach from=$options item=option}
					<option value="{$option}">{$option}</option>
					{/foreach}
					{/if}
				</select>
			{elseif $var.type == Model_CustomField::TYPE_CHECKBOX}
				<div>
					<select name="{$var_key}" id="{$var_key}" data-theme="" data-role="slider">
						<option value="0">{'common.no'|devblocks_translate|capitalize}</option>
						<option value="1">{'common.yes'|devblocks_translate|capitalize}</option>
					</select>
				</div>
			{elseif $var.type == Model_CustomField::TYPE_WORKER}
				<select name="{$var_key}" id="{$var_key}">
					<option value=""></option>
					
					{$workers = DAO_Worker::getAllActive()}
					{if is_array($workers)}
					{foreach from=$workers item=worker}
					<option value="{$worker->id}">{$worker->getName()}</option>
					{/foreach}
					{/if}
				</select>
			{else}
				{* [TODO] List choosers *}
			{/if}
		</div>
		
		{/if}
	{/foreach}
	{/if}
	
	<button type="button" class="submit" data-inline="true" data-theme="b" class="ui-btn-hidden" aria-disabled="false">Send</button><!--
	--><button type="reset" data-theme="c" data-inline="true" class="ui-btn-hidden" aria-disabled="false">Reset</button>

	</form>
	
	<div id="cerb-va-output" style="margin-top:20px;"></div>
</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

<script type="text/javascript">

$('#page-va-behavior').on('pageinit',function(event){
	$(this).on('click','button.submit',function() {
		$.mobile.loading('show', {
			text: 'Sending...',
			textVisible: true,
			theme: 'a',
			html: ''
		});
		
		$.post("{devblocks_url}ajax.php?c=m&a=runVirtualAttendantBehavior{/devblocks_url}", $('#form-cerb-va-behavior-run').serialize(), function(out) {
			var $output = $('#cerb-va-output');
			$('#cerb-va-output').html(out);
			
			var top = $output.offset().top - 45;
			
			$.mobile.loading('hide');
			$.mobile.silentScroll(top);
		});
	});
  
});

</script>

</div><!-- /page -->

</body>
</html>
