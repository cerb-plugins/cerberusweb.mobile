<b>Send this worklist variable as a message:</b>
<div style="margin-left:10px;margin-bottom:10px;">
	<select name="{$namePrefix}[var_key]">
		<option value=""></option>
		
		{foreach from=$trigger->variables item=var key=var_key}
			{if substr($var.type,0,4) == 'ctx_'}
			{$context_ext_id = substr($var.type,4)}
			{$context_ext = Extension_DevblocksContext::get($context_ext_id)}
			<option value="{$var_key}" {if $params.var_key==$var_key}selected="selected"{/if}>{$var.label} ({$context_ext->manifest->name})</option>
			{/if}
		{/foreach}
	</select>
</div>

<script type="text/javascript">
$action = $('fieldset#{$namePrefix}');
</script>
