# 프로그래머스 Idus 앱 개발 과제 - 상품 목록 조회 API
상품 목록을 ( 50개 ) 단위로 조회 할 수 있고, 상세 정보 조회와 페이징 기능을 가진 상품 목록 조회 API

## 개발 과제 설명
<img src="images/idus_앱개발과제.png" width="50%" height="50%"> 

API를 사용하여 위와 같은 어플리케이션 개발 ( iOS or Android )

# API REFERENCE

### BASE URL
- https://2jt4kq01ij.execute-api.ap-northeast-2.amazonaws.com/prod/

    > BASE URL 뒤에 원하는 리소스를 붙혀 사용합니다.  
    ex) {BASE URL}/products?page=10

## Products API - Get 메소드
상품 목록을 조회 할 수 있는 기능 
```
GET /products -> 상품 목록을 반환합니다. (50개 단위 페이징)

GET /products?page={페이지 번호} -> 페이지 번호에 해당되는 상품 목록을 반환합니다. 
```

#### Request Header 구조
```
GET /products
Content-Type: application/json
```

### 1. 페이징 기능

#### QueryParameter (선택)
| Parameter | Type   | Description |
|----------------|--------|-------------|
| page           | Integer | 페이지 번호 |

#### 요청 예시 - cURL
```
1. curl -G https://2jt4kq01ij.execute-api.ap-northeast-2.amazonaws.com/prod/products -H "Content-Type: application/json"

curl -G https://2jt4kq01ij.execute-api.ap-northeast-2.amazonaws.com/prod/products?page=10 -H "Content-Type: application/json"

2. 웹 브라우저에서 테스트
https://2jt4kq01ij.execute-api.ap-northeast-2.amazonaws.com/prod/products?page=10
```

#### Response Body 예시
```
{
  "statusCode": 200,
  "body": [
    {
      "id": 1,
      "thumbnail_520": "https://image.idus.com/image/files/4e47e2fa54e84fedbe56b610475adf0c_520.jpg",
      "title": "겨울에 아삭한여름복숭아먹기",
      "seller": "골든팜"
    },
    ....
    ....
}
```

#### Response Body 설명
| Column     | Type      | Description   |
|------------|-----------|---------------|
| id       | Integer    | 상품 코드      |
| thumbnail_520 | String |  썸네일 이미지 (520 size) |
| title    | String    | 게시글 제목      |
| seller  | String    | 게시글 작성자     |

### 2. 상세 정보 조회 기능

#### PathParameters (선택)
| Parameter | Type   | Description |
|----------------|--------|-------------|
| id        | Integer | 상품 코드 |

#### 요청 예시 - cURL
```
1. curl -G https://2jt4kq01ij.execute-api.ap-northeast-2.amazonaws.com/prod/products/250 -H "Content-Type: application/json"

2. 웹 브라우저에서 테스트
https://2jt4kq01ij.execute-api.ap-northeast-2.amazonaws.com/prod/products/250
```

#### Response Body 예시
```
{
  "statusCode": 200,
  "body": [
    {
      "id": 250,
      "thumbnail_720": "https://image.idus.com/image/files/0b9ca2fae287417b95c87fe59e01f31b_720.jpg",
      "thumbnail_list_320": "https://image.idus.com/image/files/0b9ca2fae287417b95c87fe59e01f31b_320.jpg#https://image.idus.com/image/files/fa2e0876ad6b4f468eb11f7e1a16adda_320.jpg .....",
      "title": "[밀호밀] 원 스트랩 백 S사이즈",
      "seller": "milhomil",
      "cost": "20,000원",
      "discount_cost": null,
      "discount_rate": null,
      "description": "\n\n[밀호밀] 원 스트랩 백\n\nmaterial : 코튼 100％\n\ncolor : 베이지, 블랙, 네이비, 카멜\n\n✔️ 내부에 포켓이 생겼습니다😉\n ....."
    }
  ]
}
```

#### Response Body 설명
| Column     | Type      | Description   |
|------------|-----------|---------------|
| id       | Integer    | 상품 코드      |
| thumbnail_720 | String |  썸네일 이미지 (720 size) |
| thumbnail_list_320 | String |  썸네일 이미지 (320 size) -> 각 이미지는 #으로 구분되어있음 |
| title    | String    | 게시글 제목      |
| seller  | String    | 게시글 작성자     |
| cost | String | 상품 원가 |
| discount_cost | String | 상품 할인가 |
| discount_rate | String | 상품 할인율 |
| description | String | 상품 설명 |

#### Response Status Code
| Status Code               | Description                                       |
|---------------------------|---------------------------------------------------|
| 200 OK                    | 성공                                              |
| 400 Bad Request           | 클라이언트 요청 오류 - 요청 변수가 Integer 타입이 아닐 때  |
| 404 NotFound              | 조회한 데이터가 비어있을 때, URL 경로, HTTP method 오류로 페이지를 찾을 수 없을 때 |
| 500 Internal Server Error | 서버에 문제가 있을 경우                           |



