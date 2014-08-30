<!DOCTYPE html>
<html>

{include file="devblocks:cerberusweb.mobile::html_head.tpl"}

<body>

<div data-role="page" id="page-va-behaviors" data-theme="a">

{include file="devblocks:cerberusweb.mobile::header.tpl"}

<div data-role="content">
	<div data-role="controlgroup" data-mini="true" data-type="horizontal" data-theme="a" style="margin:0px 0px 10px 0px;">
		<a href="{devblocks_url}c=m&p=va{/devblocks_url}" data-role="button">Attendants</a>
	</div>

	<div class="choice_list">
		<h3>{$va->name}</h3>
		
		<ul data-role="listview" data-inset="true" data-filter="true">
			{foreach from=$behaviors item=behavior key=behavior_id}
			<li>
				<a href="{devblocks_url}c=m&a=va&w=behavior&id={$behavior_id}{/devblocks_url}" data-transition="fade">
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