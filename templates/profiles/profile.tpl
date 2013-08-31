<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-profile" data-theme="c">

{include file="devblocks:cerberusweb.mobile::panel.tpl"}

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<a data-role="button" data-direction="reverse" data-rel="back" data-icon="arrow-l" data-iconpos="left" class="ui-btn-left">Back</a>
	<h1>Cerb Mobile</h1>
	<a href="#cerb-panel" data-role="button" data-icon="bars" data-iconpos="notext" class="ui-btn-right">Menu</a>
</div>

<div data-role="content">
	<h3 style="margin:0px 0px 0px 0px;">{$dict->_label}</h3>
	<div style="margin-bottom:20px;">
		{$context_ext->manifest->name}
	</div>

	{if method_exists($context_ext, 'getDefaultProperties')}
		{$props = $context_ext->getDefaultProperties()}
	
		<div data-role="collapsible" data-inset="false" data-collapsed="false" data-collapsed-icon="arrow-r" data-expanded-icon="arrow-d">
		<h3>Properties</h3>
		
		<table data-role="table" data-mode="reflow" style="margin-top:0px;">
		
		<thead>
			<tr>
				{foreach from=$props item=prop_key}
					{if is_bool($dict->$prop_key) || strlen($dict->$prop_key) > 0}
					<th>
						{if method_exists($context_ext, 'formatDictionaryLabel')}
							{$context_ext->formatDictionaryLabel($prop_key, $dict)}
						{elseif isset($labels.$prop_key)}
							{$labels.$prop_key}
						{else}
							{$prop_key}
						{/if}
					</th>
					{/if}
				{/foreach}
			</tr>
		</thead>
		
		<tbody>
			<tr>
				{foreach from=$props item=prop_key}
				{if is_bool($dict->$prop_key) || strlen($dict->$prop_key) > 0}
					<td>
					{if method_exists($context_ext, 'formatDictionaryValue')}
						{$val = $context_ext->formatDictionaryValue($prop_key, $dict)}
						{$val_type = $dict->_types.$prop_key}
						
						{if $val_type == 'context_url'}
							{if preg_match('#ctx://(.*?):([0-9]+)/*(.*)$#', $val, $matches)}
								<a href="{devblocks_url}c=m=&p=profile&ctx={$matches[1]}&id={$matches[2]}{/devblocks_url}" data-transition="slide">{$matches[3]|default:'link'}</a>
							{else}
								{$val}
							{/if}
							
						{elseif $val_type == Model_CustomField::TYPE_URL}
							{$val|escape:'htmlall'|devblocks_hyperlinks nofilter}
							
						{else}
							{$val|escape:'htmlall'|nl2br nofilter}
						{/if}
						
					{else}
						{$dict->$prop_key|escape:'htmlall'|nl2br nofilter}
					{/if}
					</td>
				{/if}
				
				{/foreach}
			</tr>
		</tbody>
		
		</table>
		</div>
	{/if}
	
	{* Temporary *}
	<div data-role="collapsible" data-inset="false" data-collapsed-icon="arrow-r" data-expanded-icon="arrow-d" class="cerb-profile-properties">
		<h3>Dictionary</h3>
		
		{foreach from=$labels item=label key=key}
			<dl>
				<dt>{$key}</dt>
				<dd></dd>
			</dl>
		{/foreach}
	</div>
	
	{$meta = $context_ext->getMeta($context_id)}
	{if $meta.permalink}
	<a href="{$meta.permalink}" target="_blank" data-theme="b" data-role="button">View full record</a>
	{/if}
</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

<script type="text/javascript">

$('#page-profile').on('pageinit',function(event){
	$(this).on('click','button.submit',function() {
		/*
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
		*/
	});
  
});

</script>

</div><!-- /page -->

</body>
</html>
