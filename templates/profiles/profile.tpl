<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-profile" data-theme="c">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">
	<h3 style="margin:0px 0px 0px 0px;">{$dict->_label}</h3>
	<div style="margin-bottom:20px;">
		{$context_ext->manifest->name}
	</div>

	{if method_exists($context_ext, 'getDefaultProperties')}
	{$props = $context_ext->getDefaultProperties()}
	
	<div data-role="collapsible" data-inset="false" data-collapsed="false" data-collapsed-icon="arrow-r" data-expanded-icon="arrow-d" style="margin-bottom:0px;">
		<h3 style="margin:0;">Properties</h3>

		<div>
		{foreach from=$props item=prop_key}
			{if method_exists($context_ext, 'formatDictionaryValue')}
				{$val = $context_ext->formatDictionaryValue($prop_key, $dict)}
			{else}
				{$val = $dict->$prop_key}
			{/if}
			
			{if strlen($val) > 0}
			<p style="margin-top:0;margin-bottom:10px;">
				<b>{$dict->_labels.$prop_key}:</b>
				
				{$val_type = $dict->_types.$prop_key}
				{if $val_type == 'context_url'}
					{if preg_match('#ctx://(.*?):([0-9]+)/*(.*)$#', $val, $matches)}
						<a href="{devblocks_url}c=m=&p=profile&ctx={$matches[1]}&id={$matches[2]}{/devblocks_url}" data-transition="slide">{$matches[3]|default:'link'}</a>
					{/if}
					
				{else}
					{$val|escape:'htmlall'|nl2br nofilter}
				{/if}
			</p>
			{/if}
		{/foreach}
		</div>
	</div>
	{/if}
	
	{$meta = $context_ext->getMeta($context_id)}
	{if $meta.permalink}
	<a href="{$meta.permalink}" target="_blank" data-theme="b" data-role="button">View full record</a>
	{/if}
</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</script>

</div><!-- /page -->

</body>
</html>
