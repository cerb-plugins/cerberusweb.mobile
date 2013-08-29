<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-va-behaviors" data-theme="c">

<div data-theme="a" data-role="header" data-id="cerb-header" data-position="fixed">
	<a href="{devblocks_url}c=m&a=va{/devblocks_url}" data-role="button" data-icon="arrow-l" data-iconpos="left" class="ui-btn-left">Attendants</a>
	<h1>Cerb Mobile</h1>
</div>

<div data-role="content">

	<div class="choice_list">
		<h3>{$va->name}</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$behaviors item=behavior key=behavior_id}
			<li>
				<a href="{devblocks_url}c=m&a=va&w=behavior&id={$behavior_id}{/devblocks_url}" data-transition="slidedown">
					<h3 class="ui-li-heading">{$behavior->title}</h3>
				</a>
			</li>
			{/foreach}
		</ul>
	</div>

</div>

{include file="devblocks:cerberusweb.mobile::footer.tpl"}

</div><!-- /page -->

</body>

</html>