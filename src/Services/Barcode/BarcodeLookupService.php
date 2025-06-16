<?php
namespace App\Services\Barcode;

use App\Services\InfoProviderSystem\Providers\MouserProvider;

class BarcodeLookupService
{
    public function __construct(private MouserProvider $mouserProvider)
    {
    }

    public function lookup(string $barcode): array
    {
        if ($barcode === '') {
            return [];
        }

        $results = $this->mouserProvider->searchByKeyword($barcode);
        if (count($results) === 0) {
            return [];
        }

        $part = $results[0];

        return [
            'name' => $part->name,
            'manufacturer' => $part->manufacturer,
            'mpn' => $part->mpn,
            'datasheet' => $part->datasheets[0]->url ?? null,
            'product_url' => $part->provider_url,
        ];
    }
}
