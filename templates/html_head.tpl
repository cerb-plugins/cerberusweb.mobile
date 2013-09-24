<head>
	<title>{$settings->get('cerberusweb.core','helpdesk_title')}</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, minimum-scale=1">
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="black" />

	<!-- iPhone -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-57x57.png{/devblocks_url}?v={$plugin_manifest->version}"
		  sizes="57x57"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-320x460.png{/devblocks_url}?v={$plugin_manifest->version}"
		  media="(device-width: 320px) and (device-height: 480px)
			 and (-webkit-device-pixel-ratio: 1)"
		  rel="apple-touch-startup-image">

	<!-- iPhone (Retina) -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-114x114.png{/devblocks_url}?v={$plugin_manifest->version}"
		  sizes="114x114"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-640x920.png{/devblocks_url}?v={$plugin_manifest->version}"
		  media="(device-width: 320px) and (device-height: 480px)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">

	<!-- iPhone 5 -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-640x1096.png{/devblocks_url}?v={$plugin_manifest->version}"
		  media="(device-width: 320px) and (device-height: 568px)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">

	<!-- iPad -->
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-72x72.png{/devblocks_url}?v={$plugin_manifest->version}"
		  sizes="72x72"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-768x1004.png{/devblocks_url}?v={$plugin_manifest->version}"
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
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-144x144.png{/devblocks_url}?v={$plugin_manifest->version}"
		  sizes="144x144"
		  rel="apple-touch-icon-precomposed">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-1536x2008.png{/devblocks_url}?v={$plugin_manifest->version}"
		  media="(device-width: 768px) and (device-height: 1024px)
			 and (orientation: portrait)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">
	<link href="{devblocks_url full=true}c=resource&p=cerberusweb.mobile&f=images/cerby-splash-1496x2048.png{/devblocks_url}?v={$plugin_manifest->version}"
		  media="(device-width: 768px) and (device-height: 1024px)
			 and (orientation: landscape)
			 and (-webkit-device-pixel-ratio: 2)"
		  rel="apple-touch-startup-image">

	<link rel="stylesheet" href="{devblocks_url}c=resource&p=cerberusweb.mobile&f=css/flat/jquery.mobile.flatui.min.css{/devblocks_url}?v={$plugin_manifest->version}" />
	<link rel="stylesheet" href="{devblocks_url}c=resource&p=cerberusweb.mobile&f=css/cerb.css{/devblocks_url}?v={$plugin_manifest->version}" />
	
	<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=js/moment.js{/devblocks_url}?v={$plugin_manifest->version}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery-core.min.js{/devblocks_url}?v={$plugin_manifest->version}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=cerberusweb.mobile&f=js/jquery.mobile.min.js{/devblocks_url}?v={$plugin_manifest->version}"></script>
	<script type="text/javascript" src="{devblocks_url}c=resource&p=devblocks.core&f=js/jquery/_development/jquery.devblocksCharts.js{/devblocks_url}?v={$plugin_manifest->version}"></script>
	
	<script type="text/javascript">
		$(document).on('pagebeforeshow', function() {
			$.mobile.activePage.find('#cerb-panel').on('click', '.cerb-panel-toggle-bookmark', function(e) {
				var $this = $(this);
				var current_path = $.mobile.path.parseUrl($.mobile.urlHistory.getActive().url).pathname;
				var bookmarks = (localStorage.bookmarks_json) ? JSON.parse(localStorage.bookmarks_json) : null;
				
				if(null == bookmarks || typeof bookmarks != 'object')
					bookmarks = [];
	
				var is_current_page_bookmarked = false;
				
				for(idx in bookmarks) {
					if(bookmarks[idx].path == current_path) {
						is_current_page_bookmarked = idx;
						break;
					}
				}
				
				if(false !== is_current_page_bookmarked) {
					bookmarks.splice(is_current_page_bookmarked, 1);
					
				} else {
					var bookmark = {
						'label': $.mobile.activePage.find('h3:first').text(),
						'path': current_path
					};
					
					bookmarks.push(bookmark);
				}
	
				// Alphabetize bookmarks
				bookmarks.sort(function(a,b) { return a.label > b.label; });
				
				localStorage.bookmarks_json = JSON.stringify(bookmarks);
				
				// Redraw
				$.mobile.activePage.find('#cerb-panel').trigger('panelrefresh');
			});
			
			$.mobile.activePage.find('#cerb-panel').on('panelbeforeopen panelrefresh', function(e) {
				var $ul = $(this).find('ul.cerb-panel-bookmarks');
				var bookmarks = (localStorage.bookmarks_json) ? JSON.parse(localStorage.bookmarks_json) : null;
				
				var current_path = $.mobile.path.parseUrl($.mobile.urlHistory.getActive().url).pathname;
				
				var page_title = $.mobile.activePage.find('h3:first').text();
				
				$ul.find('li').not('.ui-li-divider').remove();
	
				if(null == bookmarks || typeof bookmarks != 'object')
					bookmarks = [];
				
				var is_current_page_bookmarked = false;
	
				for(idx in bookmarks) {
					if(bookmarks[idx].path == current_path)
						is_current_page_bookmarked = true;
					
					var $li = $('<li><a href="' + bookmarks[idx].path + '">' + bookmarks[idx].label + '</a></li>');
					$li.appendTo($ul);
				}
				
				// Insert an add/remove button depending on current page
				if(false !== is_current_page_bookmarked) {
					var $li = $('<li data-theme="a" data-icon="minus" data-iconpos="left"><a href="javascript:;" class="cerb-panel-toggle-bookmark">Remove: ' + page_title + '</a></li>');
					$li.appendTo($ul);
					
				} else {
					var $li = $('<li data-theme="a" data-icon="plus" data-iconpos="left"><a href="javascript:;" class="cerb-panel-toggle-bookmark">Add: ' + page_title + '</a></li>');
					$li.appendTo($ul);
				}
				
				$ul.listview('refresh');
			});
		});
		
	</script>

</head>
