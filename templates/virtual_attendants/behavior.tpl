<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-va-behavior{$behavior->id}" data-theme="c" class="cerb-page-va-behavior">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">
	<div data-role="controlgroup" data-mini="true" data-type="horizontal" data-theme="a" style="margin:0px 0px 10px 0px;">
		<a href="{devblocks_url}c=m&p=va{/devblocks_url}" data-role="button">Attendants</a>
		<a href="{devblocks_url}c=m&p=va&id={$va->id}{/devblocks_url}" data-role="button">{$va->name}</a>
	</div>

	<form action="{devblocks_url}c=m&a=va&p=run&id={$behavior->id}{/devblocks_url}" method="post">

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
					<select name="{$var_key}" id="{$var_key}" data-role="slider">
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
	
	<button type="submit" data-inline="true" data-theme="a" class="ui-btn-hidden" aria-disabled="false">Run behavior</button>

	</form>
</div>

</div><!-- /page -->

</body>
</html>
