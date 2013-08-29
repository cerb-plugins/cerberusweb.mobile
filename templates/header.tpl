<head>
	<title>{$settings->get('cerberusweb.core','helpdesk_title')}</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="{devblocks_url}c=resource&p=cerberusweb.mobile&f=css/jquery.mobile.min.css{/devblocks_url}?v={$smarty.const.APP_BUILD}" />
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery-core.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=js/jquery.mobile.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery.devblocksCharts.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	
	<style>
		.ui-page h1, .ui-page h2, .ui-page h3 {
			margin: 0px 0px 15px 0px;
		}
		
		.ui-li-aside {
			width: auto !important;
			margin: 0px -20px 0px 0px;
			overflow: visible;
		}
		
		#cerb-footer {
			border: 0;
		}
		
		#cerb-footer .ui-navbar .ui-btn-inner {
			padding-top:35px;
		}
		
		#cerb-footer .ui-navbar .ui-btn-active {
			background:none !important;
			border-color:black;
		}
		
		#cerb-footer .ui-navbar .ui-icon {
			box-shadow: none;
			-moz-box-shadow: none;
			-webkit-box-shadow: none;
		}
		
		#cerb-footer .ui-btn-text {
			font-weight: normal;
			top: 2px;
		}
		
		#cerb-footer .ui-icon-cerb-badge-count {
			background-repeat: no-repeat !important;
			background: none !important;
			text-shadow: none;
			height: 16px;
			width: 30px;
			line-height: 16px;
			padding: 2px 4px;
			margin-left: -19px;
			top: 12px;
			font-size: 16px;
			{if $notification_count}background-color: rgb(200,0,0) !important;{/if}
			{if !$notification_count}background-color: rgb(100,100,100) !important;{/if}
		}

		#cerb-footer .ui-icon-cerb-workspaces {
			background-color: none;
			background: url({devblocks_url}c=resource&p=cerberusweb.mobile&f=css/images/wgm/cerb-sprites.png{/devblocks_url}) no-repeat top left;
			background-position: 0 -82px; width: 32px; height: 32px;
			border-radius: 0;
			height: 32px;
			width: 32px;
			margin-left: -16px;
			top: 5px;
		}
		
		#cerb-footer .ui-icon-cerb-vas {
			background-color: none;
			background: url({devblocks_url}c=resource&p=cerberusweb.mobile&f=css/images/wgm/cerb-sprites.png{/devblocks_url}) no-repeat top left;
			background-position: 0 0; width: 32px; height: 32px;
			border-radius: 0;
			height: 32px;
			width: 32px;
			margin-left: -16px;
			top: 5px;
		}

		#page-notifications h3.ui-li-heading {
			overflow: visible;
			white-space: normal;
		}
		
		#page-va-behavior .cerb-va-message a {
			font-weight: bold;
			color: black;
			word-wrap: break-word;
			word-break: break-all;
		}
	</style>

	<script type="text/javascript">
		$(document).on('pagebeforeshow', function() {
			$(".ui-icon-shadow").removeClass('ui-icon-shadow');
			
			var $badge = $('#cerb-footer .ui-icon-cerb-badge-count');
			$badge.removeClass('ui-icon-shadow');
			$badge.html('{$notification_count|default:0}');
		});
	</script>

</head>
