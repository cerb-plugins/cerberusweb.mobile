<div id="cerb-footer" data-theme="a" data-role="footer" data-id="cerb-footer" data-position="fixed">
	<div data-role="navbar" data-iconpos="top">
		<ul>
			<li>
				<a href="{devblocks_url}c=m&a=notifications{/devblocks_url}" data-transition="fade" data-theme="" data-icon="cerb-badge-count" class="{if $controller == 'notifications'}ui-btn-active{/if}">
					Notifications
				</a>
			</li>
			<li>
				<a href="{devblocks_url}c=m&a=workspaces{/devblocks_url}" data-transition="fade" data-theme="" data-icon="cerb-workspaces" class="{if $controller == 'workspaces' || $controller == 'workspace'}ui-btn-active{/if}">
					Workspaces
				</a>
			</li>
			<li>
				<a href="{devblocks_url}c=m&a=va{/devblocks_url}" data-transition="fade" data-theme="" data-icon="cerb-vas" class="{if $controller == 'va'}ui-btn-active{/if}">
					Attendants
				</a>
			</li>
		</ul>
	</div>
</div>
