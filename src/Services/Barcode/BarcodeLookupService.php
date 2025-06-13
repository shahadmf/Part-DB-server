<?php
namespace App\Services\Barcode;

use Symfony\Contracts\HttpClient\HttpClientInterface;

class BarcodeLookupService
{
    public function __construct(private HttpClientInterface $httpClient, private string $apiKey)
    {
    }

    public function lookup(string $barcode): array
    {
        if ($barcode === '') {
            return [];
        }

        $url = 'https://api.barcodelookup.com/v3/products';
        $response = $this->httpClient->request('GET', $url, [
            'query' => [
                'barcode' => $barcode,
                'key' => $this->apiKey,
                'formatted' => 'y',
            ],
        ]);

        if ($response->getStatusCode() !== 200) {
            return [];
        }

        $data = $response->toArray(false);
        if (!isset($data['products'][0])) {
            return [];
        }

        $product = $data['products'][0];

        return [
            'name' => $product['title'] ?? null,
            'manufacturer' => $product['manufacturer'] ?? null,
            'mpn' => $product['mpn'] ?? null,
            'datasheet' => $product['datasheet'] ?? null,
        ];
    }
}
