<?php
namespace App\Controller;

use App\Services\Barcode\BarcodeLookupService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class BarcodeLookupController extends AbstractController
{
    #[Route(path: '/api/barcode_lookup', name: 'barcode_lookup')]
    public function lookup(Request $request, BarcodeLookupService $service): Response
    {
        $barcode = $request->query->get('barcode', '');
        if ($barcode === '') {
            return $this->json(['error' => 'No barcode provided'], Response::HTTP_BAD_REQUEST);
        }

        try {
            $data = $service->lookup($barcode);
        } catch (\Throwable $e) {
            return $this->json(['error' => 'Lookup failed'], Response::HTTP_BAD_GATEWAY);
        }

        return $this->json($data);
    }
}
