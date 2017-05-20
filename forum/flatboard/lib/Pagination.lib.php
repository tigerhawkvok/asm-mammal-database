<?php defined('FLATBOARD') or die('Flatboard Community.');

/*
 * Project name: Flatboard
 * Project URL: http://flatboard.free.fr
 * Author: Frédéric Kaplon and contributors
 * All Flatboard code is released under the MIT license.
*/

class Paginate
{
    /**
     * Protected constructor since this is a static class.
     *
     * @access  protected
     */
    protected function __construct()
    {
        // Nothing here
    }
    	
	public static function pageLink($p, $total, $loc)
	{
		$start = ($p-4) >= 1? $p-4 : 1;
		$end = ($p+4) <= $total? $p+4 : $total;
		$out = '<nav class="pagination">
		<ul class="align-center">'.
		    ($p > 1? '<li class="prev"><a href="' .$loc. DS . 'p' . DS .($p-1). '">&larr;</a></li>' : '').
			($start === 1? '' : '<li><a href="' .$loc. DS . 'p' . DS .($start-1). '">…</a></li>');
			for($i=$start; $i<=$end; $i++)
			{
				if($p === $i)
					$out .= '<li><span>' .$i. '</span></li>';
				else
					$out .= '<li><a href="' .$loc. DS . 'p' . DS .$i. '">' .$i. '</a></li>';	
			}
			$out .= ($end === $total? '' : '<li><a href="' .$loc. DS . 'p' . DS .($end+1). '">…</a></li>').
			($p < $total? '<li class="next"><a href="' .$loc. DS . 'p' . DS .($p+1). '">&rarr;</a></li>' : '');
		$out.= '</ul>
		</nav>';
		return $out;
	}
	
	public static function countPage($items, $nb)
	{
		$itemNum = count($items);
		if($itemNum === 0)
			return 1;
		else
			return (int) ceil($itemNum / $nb);
	}
	
	public static function viewPage($items, $p, $nb)
	{
		return array_slice($items, $nb*($p-1), $nb);
	}
	
	public static function pid($total)
	{
		if(!Util::isGET('p'))
			return 1;
		$p = (int) $_GET['p'];
		if($p >= 1 && $p <= $total)
			return $p;
		else
			return 1;
	}

}