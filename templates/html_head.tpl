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
	<link rel="stylesheet" href="{devblocks_url}c=resource&p=cerberusweb.mobile&f=css/cerb.css{/devblocks_url}?v={$smarty.const.APP_BUILD}" />
	
	<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=js/moment.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery-core.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=js/jquery.mobile.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery.devblocksCharts.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
	
	<script type="text/javascript">
		$(document).on('pagebeforeshow', function() {
			$(".ui-icon-shadow").removeClass('ui-icon-shadow');
			
			var $badge = $('#cerb-footer .ui-icon-cerb-badge-count');
			$badge.removeClass('ui-icon-shadow');
			$badge.html('{$notification_count|default:0}');
		});
	</script>

</head>
