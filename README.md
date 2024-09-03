# ASCON


`K`: Khóa bí mật secret key K của k ≤ 160 bits

`N, T`: Nonce N, thẻ Tag T, all 128 bit

`P, C, A`: Văn bản thuần Plaintext P,  bản mã ciphertext C, dữ liệu liên quan associated data A (trong các khối r-bit Pi, Ci, Ai)

`M, H`: Message M, hash value H (in r-bit blocks Mi, Hi)

`⊥`: Error, xác minh bản mã xác thực không thành công

## ✨Initialization

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/03db3bf3-25e3-42b0-9e44-319499ecc82c/image.png)

### Vector Khởi Tạo (`IV`)

Vector Khởi Tạo được tạo ra bằng cách nối các tham số sau:

> **`k`**: Kích thước khóa 128bit
> 

> **`r`**: Tốc độ (rate), là độ dài của khối sẽ được xử lý trong quá trình mã hóa.
> 

> **`a`**: Số vòng lặp trong giai đoạn khởi tạo và hoàn tất.
> 

> **`b`**: Số vòng lặp trong giai đoạn xử lý dữ liệu.
> 

Thêm vào chuỗi bit số 0 có độ dài 160−k bit, đảm bảo rằng `IV` có kích thước nhất quán bất kể độ dài của khóa.

Giá trị `IV` cho các biến thể Ascon là khác nhau chúng là các hằng số, nhất quán và bảo mật trong quá trình khởi tạo:

- **80400c0600000000** cho `Ascon-128.`
- **80800c0800000000** cho `Ascon-128a`.
- **a0400c06** cho `Ascon-80pq`.

### Trạng Thái Ban Đầu (S)

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/30daa434-3684-4579-96c2-8b98b1b3c0bf/image.png)

Trạng thái ban đầu (S) được hình thành bằng cách nối IV với khóa bí mật K và nonce N:

Điều này có nghĩa là trạng thái SSS bao gồm:

1. `IV` đặc trưng cho biến thể Ascon.
2. Khóa bí mật `K` (là 128 bit cho Ascon-128/128a hoặc 80 bit cho Ascon-80pq).
3. Nonce `N`, là giá trị duy nhất cho mỗi lần mã hóa để đảm bảo rằng ngay cả với cùng một plaintext và khóa, ciphertext sẽ khác nhau.

Trạng thái ban đầu `S` này là điểm khởi đầu cho quá trình hoán vị diễn ra trong giai đoạn khởi tạo của mã hóa Ascon.

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/8437ff69-4fa4-426c-8ed6-954f471c242a/image.png)

> `pa(S)` là kết quả của**a** vòng biến đổi áp dụng lên trạng thái ban đầu `S`
> 

> 0^320−k là chuỗi bit 0 với độ dài bằng 320−k (tùy thuộc vào độ dài của khóa bí mật `K`)
> 

> `∥ K` là việc nối chuỗi số 0 này với khóa bí mật K
> 

> Phép `XOR` này sẽ cập nhật lại trạng thái `S`.
> 

## ✨Processing Associated Data

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/d4a38939-3a01-4149-9477-ec58847e0ca9/image.png)

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/ff1c68cc-d346-4667-9271-04c030111a96/image.png)

- **Bước 1: Thêm Padding**

Nếu dữ liệu liên quan  A có độ dài không phải là bội số của r, huật toán sẽ thêm một bit số 1 vào cuối A và tiếp theo là thêm một số lượng nhỏ nhất các bit 0 để tạo ra độ dài bội của  r. Điều này giúp cho A có thể được chia thành các khối có kích thước bằng nhau.

- **Bước 2: Chia Thành Các Khối**

Sau khi thêm padding, dữ liệu A sẽ được chia thành s khối, mỗi khối có độ dài r bit: A1 || ….||As.

### Với điều kiện:

> Nếu A > 0: Dữ liệu A sẽ được chia thành các khối có độ dài r, thêm bit số 1 và các bit 0 để tạo ra một bội số của r.
> 

> Nếu A = 0: không có khối nào được tạo.
> 

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/c3b0a68c-2ef6-4845-80c7-02f9a3ad9a5b/image.png)

> Sr: Phần đầu tiên của trạng thái S, gồm r bit (r = 64 bit)
> 

> Sc: Phần còn lại của trạng thái S, gồm 320 -r bit (ví dụ: 256 bit đối với Ascon-128).
> 

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/2e625b87-054f-4f66-8382-e060f7c05857/image.png)

## ✨Processing Plaintext

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/d4c7caec-f8e3-4dbe-afdb-54bf6f1a4778/image.png)

Quá trình đệm thêm một số 1 và số 0

> ví dụ:
> 

**Độ dài P=100 bit. (r = 64 bit)**

- **Khối đầu tiên**: 64 bit đầu tiên của P.
- **Khối thứ hai**: 36 bit văn bản gốc + 1 bit '1' (đệm) + 27 bit '0' (đệm) để đạt tổng 64 bit cho khối thứ hai.

### Encryption

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/f132dc85-5998-401b-81ee-511455ff9dac/image.png)

Trích xuất khối bản mã `Ci` (ciphertext block `Ci`) được gán bởi `Sr` ( phần đầu tiên của trạng thái `S`) `XOR` với `Pi`

Tiếp theo, nối `Ci` với `Sc` (phần còn lại của trạng thái `S`) rồi hoán vị b lần và gán cho `S`. Với `i=t` thì không cần hoán vị.

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/194f9da6-d511-48d0-a265-44e65d8f2515/image.png)

Khối bản mã cuối cùng `Ct` được cắt ngắn theo `|P| mod r` bit đầu sao cho độ dài  nằm trong khoảng 0 đến r-1 bit. Và chiều dài của bản mã `C` giống với bản rõ `P`.

### Decryption

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/05e47574-698d-47f5-80ca-08614f6a951f/image.png)

Trừ lần lặp cuối cùng, khối bản rõ Pi được tính bằng cách `XOR` khối bản mã `Ci` với `Sr`.

Tiếp theo, nối `Ci` với `Sc`  (phần còn lại của trạng thái `S`) rồi hoán vị `b` lần và gán cho `S` (trừ khối cuối cùng).

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/9c9ef7dc-d7cd-4cb0-a2f0-4dfec87f10ef/image.png)

Khối văn bản mã hóa cuối cùng đã được cắt ngắn `Sr` và `XOR` với `Ct cuối`để lấy phần cuối của văn bản gốc:

Trạng thái `S` được cập nhật với phần đoạn văn bản gốc cuối cùng này

## ✨Finalization

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/e262c5c9-2e29-42de-877e-15dd3ef341b1/image.png)

> c là độ dài của trạng thái (256 bit), k là độ dài khóa ( 128), và r là độ dài khối(64 bit).
> 

Thẻ T bao gồm 128 bit, được XOR bởi 128 bit cuối của cả S và K

Đây là một bước quan trọng để xác định tính toàn vẹn của dữ liệu: tag (`T`) này sẽ được gửi kèm với văn bản mã hóa. Trong quá trình giải mã, tag nhận được sẽ được so sánh với tag tính toán lại để đảm bảo rằng dữ liệu không bị giả mạo hoặc thay đổi

## 🧨Permutation (hoán vị)

`Pa` và `Pb` chỉ khác nhau về số vòng. Số vòng a và số vòng b là các thông số bảo mật có thể điều chỉnh.

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/58d262fd-18ee-4f3f-b050-165b53e9ba7c/image.png)

320 bit S được chia thành 5 thanh ghi 64 bit

- Addition of Constants (Pc)
    
    ![Hằng số tròn cr được sử dụng trong mỗi vòng i của pa và pb](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/7756d2a8-557b-45c9-bf81-7524bfb8dfdf/image.png)
    
    Hằng số tròn cr được sử dụng trong mỗi vòng i của pa và pb
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/f3053cd7-c655-4546-be3b-bb19df4caac7/image.png)
    
- Substitution Layer (Ps)
    
    Sau đó lấy từng bit một của mỗi xi trong đó `x0` là `MSB` còn x4 là `LSB` và so sánh với bảng dưới đây làm lần lượt hết 64 bit.
    
    ![S-box S 5-bit của Ascon làm bảng tra cứu](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/cb3ddb75-d0e7-4cbe-addb-6d13b009be70/image.png)
    
    S-box S 5-bit của Ascon làm bảng tra cứu
    
    khi làm xong 64 lần thì sẽ có x0 → x4 mới
    
    ví dụ:
    
    | x0 | 0011 |
    | --- | --- |
    | x1 | 0101 |
    | x2 | 0010 |
    | x3 | 0110 |
    | x4 | 1100 |
    
    | x0 | 0… |
    | --- | --- |
    | x1 | 1… |
    | x2 | 0… |
    | x3 | 1… |
    | x4 | 1… |
    
    Lấy bit đầu tiên của `x0` → `x1`: 00001. Ta sẽ được số tương ứng là 1. Tra trong bảng thì ta được `S(x)` mới là b, quy đổi ra hệ thập lục phân là 01011. Tiếp tục làm 64 lần.
    
- Linear Diffusion Layer (Ps)
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/0e7c9ce0-b713-4dbe-9577-be1bbceae63b/51edbaf6-7340-42a5-a934-b620a36ff123/image.png)
    
    Σ0(x0)
    
    1. Xoay phải (dịch chuyển tròn) 19 bit.
    2. Xoay phải (dịch chuyển tròn) 28 bit.
    3. Thực hiện `XOR` giữa kết quả của các phép dịch và giá trị ban đầu `x0` để tạo ra một `x0` mới
    
    Làm tương tự cho các xi còn lại