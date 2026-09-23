<?php
require_once __DIR__.'/db.php';
function json_out($data, int $status=200): never { http_response_code($status); header('Content-Type: application/json; charset=utf-8'); echo json_encode($data, JSON_UNESCAPED_UNICODE); exit; }
function body(): array { $raw=file_get_contents('php://input'); $d=json_decode($raw,true); return is_array($d)?$d:[]; }
function bearer(): ?string { $h=$_SERVER['HTTP_AUTHORIZATION']??''; return preg_match('/Bearer\s+(\S+)/i',$h,$m)?$m[1]:null; }
function current_user(): array { $t=bearer(); if(!$t) json_out(['message'=>'Chưa đăng nhập'],401); $s=db()->prepare('SELECT u.id,u.name,u.email,u.role,u.reader_id FROM api_tokens t JOIN users u ON u.id=t.user_id WHERE t.token_hash=? AND t.expires_at>NOW()'); $s->execute([hash('sha256',$t)]); $u=$s->fetch(); if(!$u) json_out(['message'=>'Phiên đăng nhập không hợp lệ hoặc đã hết hạn'],401); return $u; }
function require_role(string $role): array { $u=current_user(); if($u['role']!==$role) json_out(['message'=>'Bạn không có quyền thực hiện chức năng này'],403); return $u; }
function need(array $d, array $keys): void { foreach($keys as $k) if(!isset($d[$k])||trim((string)$d[$k])==='') json_out(['message'=>"Thiếu dữ liệu bắt buộc: $k"],422); }
function path_parts(): array { $p=parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH); $p=preg_replace('#^/api/?#','',$p); return array_values(array_filter(explode('/',trim($p,'/')),'strlen')); }
