<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-notifications" data-theme="c">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">

	<div class="choice_list">
		<h3>Notifications</h3>
		
		<ul data-role="listview" data-inset="true" data-icon="false" data-filter="true">
			{foreach from=$notifications item=notification key=notification_id}
				{$context_ext = Extension_DevblocksContext::get($notification->context)}
				<li>
					<a href="{devblocks_url}c=m&a=profile&ctx={CerberusContexts::CONTEXT_NOTIFICATION}&id={$notification->id}{/devblocks_url}">
						<p class="ui-li-aside ui-li-desc">
							{$notification->created_date|devblocks_prettytime}
						</p>
						<h3 class="ui-li-heading">
							{$notification->message}
						</h3>
						<p class="ui-li-desc">
							{if method_exists($context_ext, 'getMeta')}
								{$meta = $context_ext->getMeta($notification->context_id)}
								{$meta.name}
							{/if}
							{if $context_ext}({$context_ext->manifest->name}){/if}
						</p>
					</a>
				</li>
			{foreachelse}
				<li>
					You have no unread notifications.
				</li>
			{/foreach}
		</ul>
	</div>

</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div>{* /page *}

</body>
</html>