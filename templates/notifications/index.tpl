<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-notifications" data-theme="c">

{include file="devblocks:cerberusweb.mobile::panel.tpl"}

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<h1>Cerb Mobile</h1>
	<a href="#cerb-panel" data-role="button" data-icon="bars" data-iconpos="notext" class="ui-btn-right">Menu</a>
</div>

<div data-role="content">

	<div class="choice_list">
		<h3>Notifications</h3>
		
		<ul data-role="listview" data-inset="true" data-icon="false" data-filter="true">
			{foreach from=$notifications item=notification key=notification_id}
				{$context_ext = Extension_DevblocksContext::get($notification->context)}
				{$meta = $context_ext->getMeta($notification->context_id)}
				<li>
					<a href="{devblocks_url}c=preferences&a=redirectRead&id={$notification->id}{/devblocks_url}" data-ajax="false" target="_blank">
						<p class="ui-li-aside ui-li-desc">
							{$notification->created_date|devblocks_prettytime}
						</p>
						<h3 class="ui-li-heading">
							{$notification->message}
						</h3>
						<p class="ui-li-desc">
							{$meta.name}
							({$context_ext->manifest->name}) 
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