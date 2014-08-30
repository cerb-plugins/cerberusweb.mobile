{$uniqid = uniqid()}
<div data-role="dialog" data-close-btn="right">
	<div data-role="header" data-theme="a">
		<h1>Virtual Attendants</h1>
	</div>
	
	<div data-role="content">
		<form id="frm{$uniqid}" method="post">
		<input type="hidden" name="c" value="m">
		<input type="hidden" name="a" value="runVaProfileBehavior">
		<input type="hidden" name="context" value="{$context}">
		<input type="hidden" name="context_id" value="{$context_id}">
		<input type="hidden" name="behavior_id" value="{$behavior->id}">
	
		<h3>{$behavior->title}</h3>
		
		<div data-role="fieldcontain">
			<label for="cerb-profile-va-when"> When should this behavior happen?</label> 
			<input name="when" id="cerb-profile-va-when" placeholder="e.g. now; tomorrow 5pm; +3 days" value="" type="text">
		</div>
		
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
		
		<button type="button" class="submit" data-inline="true" data-theme="a" class="ui-btn-hidden" aria-disabled="false">Run behavior</button>
	
		</form>
		
	</div>
	
	<script type="text/javascript">
	var $frm = $('#frm{$uniqid}');
	$frm.find('button.submit').click(function() {
		$.mobile.loading('show');
		
		$.post(
			'{devblocks_url}c=m{/devblocks_url}',
			$frm.serialize(),
			function(out) {
				window.history.go(-2);
				$.mobile.changePage(
					'{devblocks_url}c=m&a=profile&t={$context}&id={$context_id}{/devblocks_url}',
					{
						transition: 'fade',
						changeHash: false
					}
				);
			}
		);
	});
	</script>
</div>
