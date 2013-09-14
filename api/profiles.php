<?php
abstract class Extension_MobileProfileBlock extends DevblocksExtension {
	static function getAll($as_instances=false, $with_contexts=null) {
		if(!is_null($with_contexts) && !is_array($with_contexts))
			$with_contexts = array($with_contexts);
		
		$extensions = DevblocksPlatform::getExtensions('mobile.profile.block', true);
		
		if(is_array($with_contexts))
		foreach($extensions as $extension_id => $extension) {
			$allowed_contexts = array();
			
			if($as_instances) {
				$allowed_contexts = array_keys($extension->manifest->params['contexts'][0]);
			} else {
				$allowed_contexts = array_keys($extension->params['contexts'][0]);
			}
			
			foreach($with_contexts as $context) {
				if(!in_array($context, $allowed_contexts)) {
					unset($extensions[$extension_id]);
					continue;
				}
			}
		}
		
		return $extensions;
	}
	
	/**
	 * @param unknown_type $context
	 * @return Extension_DevblocksContext
	 */
	public static function get($id) {
		static $extensions = null;
		
		if(isset($extensions[$id]))
			return $extensions[$id];
		
		if(!isset($extensions[$id])) {
			if(null == ($ext = DevblocksPlatform::getExtension($id, true)))
				return;
			
			if(!($ext instanceof Extension_MobileProfileBlock))
				return;
			
			$extensions[$id] = $ext;
			return $ext;
		}
	}
	
	abstract function render(DevblocksDictionaryDelegate $dict);
};
