<head>
	<title>{$settings->get('cerberusweb.core','helpdesk_title')}</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, minimum-scale=1">
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="black" />

	<!-- iPhone -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-57x57.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  sizes="57x57"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-320x460.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  media="(device-width: 320px) and (device-height: 480px)
			 and (-webkit-device-pixel-ratio: 1)"
		  rel="apple-touch-startup-image">

	<!-- iPhone (Retina) -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-114x114.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  sizes="114x114"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-640x920.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  media="(device-width: 320px) and (device-height: 480px)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">

	<!-- iPhone 5 -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-640x1096.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  media="(device-width: 320px) and (device-height: 568px)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">

	<!-- iPad -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-72x72.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  sizes="72x72"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-768x1004.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  media="(device-width: 768px) and (device-height: 1024px)
			 and (orientation: portrait)
			 and (-webkit-device-pixel-ratio: 1)"
		  rel="apple-touch-startup-image">
	<link href="http://taylor.fausak.me/static/images/apple-touch-startup-image-748x1024.png"
		  media="(device-width: 768px) and (device-height: 1024px)
			 and (orientation: landscape)
			 and (-webkit-device-pixel-ratio: 1)"
		  rel="apple-touch-startup-image">

	<!-- iPad (Retina) -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-144x144.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  sizes="144x144"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-1536x2008.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  media="(device-width: 768px) and (device-height: 1024px)
			 and (orientation: portrait)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-1496x2048.png{/devblocks_url}?v={$smarty.const.APP_BUILD}"
		  media="(device-width: 768px) and (device-height: 1024px)
			 and (orientation: landscape)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">

	<link rel="stylesheet" href="{devblocks_url}c=resource&p=cerberusweb.mobile&f=css/jquery.mobile.min.css{/devblocks_url}?v={$smarty.const.APP_BUILD}" />
	
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery-core.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=js/jquery.mobile.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery.devblocksCharts.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	
	<style>
		.ui-page h1, .ui-page h2, .ui-page h3 {
			margin: 0px 0px 15px 0px;
		}
		
		ul.ui-listview h3.ui-li-heading, ul.ui-listview p.ui-li-desc {
			overflow: visible;
			white-space: normal;
			word-wrap: break-word;
			word-break: break-word;
		}
		
		.ui-li-aside {
			width: auto !important;
			margin: 0px -20px 0px 5px;
			overflow: visible;
		}
		
		.ui-collapsible-heading {
		}
		
		.ui-collapsible-content {
			margin-top: 0px;
			padding-top: 10px
		}
		
		.ui-table td {
			overflow: visible;
			white-space: normal;
			word-wrap: break-word;
			word-break: break-word;
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

		.ui-page .cerb-page-va-behavior-results .cerb-va-message a {
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
