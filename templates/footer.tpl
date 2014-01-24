<div id="cerb-footer" data-theme="a" data-role="footer" data-id="cerb-footer" data-position="fixed" data-tap-toggle="false">
	<div data-role="navbar" data-iconpos="top">
		<ul>
			<li>
				<a href="{devblocks_url}c=m&a=notifications{/devblocks_url}" data-transition="fade" data-icon="false" data-iconpos="notext">
					Notifications
					<span class="ui-icon ui-icon-cerb-badge-count{if $notification_count} nonzero{/if}">
						{$notification_count|default:'0'}
					</span>
				</a>
			</li>
			<li>
				<a href="{devblocks_url}c=m&a=workspaces{/devblocks_url}" data-transition="fade" data-icon="cerb-workspaces">
					Workspaces
				</a>
			</li>
			<li>
				<a href="{devblocks_url}c=m&a=va{/devblocks_url}" data-transition="fade" data-icon="cerb-vas">
					Attendants
				</a>
			</li>
		</ul>
	</div>
</div>

<script type="text/javascript">
// Update the footer on all cached pages
$(function() {
$.mobile.pageContainer.find('.ui-footer .ui-icon-cerb-badge-count')
	.html('{$notification_count}')
	{if $notification_count}.addClass('nonzero'){else}.removeClass('nonzero'){/if}
	;
});
</script>