<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-profile-{$context|replace:'.':''}-{$context_id}" data-theme="c">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">
	<h3 style="margin:0;white-space:normal;word-wrap:break-word;word-break:break-word;">{$dict->_label}</h3>
	<div style="margin-bottom:20px;">
		<div>
		{$context_ext->manifest->name}
		</div>
	
		{if !empty($macros)}
		<a href="{devblocks_url}ajax.php?c=m&a=showProfileVaBehaviorMenu&context={$context}&context_id={$context_id}{/devblocks_url}" data-rel="dialog" data-transition="flip" data-role="button" data-theme="c" data-icon="arrow-d" data-iconpos="right">Virtual Attendants</a>
		{/if}
	</div>

	{if method_exists($context_ext, 'getDefaultProperties')}
	{$props = $context_ext->getDefaultProperties()}
	
	<h3 style="margin-bottom:5px;">Properties</h3>

	{if method_exists($context_ext, 'getPropertyLabels')}
		{$prop_labels = $context_ext->getPropertyLabels($dict)}
	{else}
		{$prop_labels = $dict->_labels}
	{/if}

	<div style="padding:0px 5px 5px 5px;">
	<table cellspacing="0" cellpadding="3" width="100%" border="0" style="font-size:12px;font-weight:normal;white-space:normal;word-wrap:break-word;word-break:break-word;">
	{foreach from=$props item=prop_key}
		{if method_exists($context_ext, 'formatDictionaryValue')}
			{$val = $context_ext->formatDictionaryValue($prop_key, $dict)}
		{else}
			{$val = $dict->$prop_key}
		{/if}
		
		{if strlen($val) > 0}
			<tr>
				<td style="width:30%;" valign="top">
					<div style="font-weight:bold;padding-left:5px;text-indent:-5px;">{$prop_labels.$prop_key}:</div>
				</td>
				<td style="width:70%;padding-left:5px;">
					{$val_type = $dict->_types.$prop_key}
					{if $val_type == 'context_url'}
						{if preg_match('#ctx://(.*?):([0-9]+)/*(.*)$#', $val, $matches)}
							<a href="{devblocks_url}c=m=&p=profile&ctx={$matches[1]}&id={$matches[2]}{/devblocks_url}" data-transition="slide">{$matches[3]|default:'link'}</a>
						{else}
							{$val}
						{/if}

					{elseif $val_type == 'phone'}
						<a href="tel:{$val}">{$val}</a>
						
					{elseif $val_type == Model_CustomField::TYPE_URL}
						<a href="{$val}" target="_blank">{$val}</a>
					{else}
						{$val|escape:'htmlall'|nl2br nofilter}
					{/if}
				</td>
			</tr>
		{/if}
	{/foreach}
	</table>
	</div>
	{/if}
	
	{foreach from=$mobile_profile_extensions item=mobile_profile_ext}
		{$mobile_profile_ext->render($dict)}
	{/foreach}
	
	{if isset($comments)}
		<h3 style="margin-top:10px;margin-bottom:10px;">Comments</h3>
		
		<div style="font-size:12px;" class="cerb-profile-comment">
		{CerberusContexts::getContext(CerberusContexts::CONTEXT_COMMENT, end($comments), $null, $comment_values)}
		{$comment_dict = DevblocksDictionaryDelegate::instance($comment_values)}
		{include file="devblocks:cerberusweb.mobile::profiles/comments/comment.tpl" context=$dict->_context context_id=$dict->id dict=$comment_dict}
		</div>
	{/if}
	
	{$meta = $context_ext->getMeta($context_id)}
	{if $meta.permalink}
	<a href="{$meta.permalink}" target="_blank" data-theme="b" data-role="button">View record in full site</a>
	{/if}
</div>

</div><!-- /page -->

</body>
</html>
