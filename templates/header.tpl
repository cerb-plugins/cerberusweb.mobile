{include file="devblocks:cerberusweb.mobile::panel.tpl"}

<div data-theme="c" data-role="header" data-id="cerb-header" data-position="fixed" data-tap-toggle="false">
	<a data-theme="c" data-role="button" data-direction="reverse" data-rel="back" data-icon="carat-l" data-iconpos="left" class="ui-nodisc-icon">Back</a>
	<h1>
		{if $header_icon}
		<img src="{$header_icon}" style="height:24px;width:24px;border-radius:12px;margin-right:5px;vertical-align:middle;">
		{else}
		<img src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=images/cerb_logo_white.png{/devblocks_url}" height="24">
		{/if}
		{$header_title}
	</h1>
	<a href="#cerb-panel" data-theme="c" data-role="button" data-icon="bars" class="ui-nodisc-icon">Menu</a>
</div>
