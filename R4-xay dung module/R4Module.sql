--SCRIPT TẠO BẢNG
USE master;  
GO  

IF DB_ID (N'QuanLyBanHang') IS NOT NULL  
DROP DATABASE QuanLyBanHang;  
GO  

CREATE DATABASE QuanLyBanHang  
go

use QuanLyBanHang
go

--Tao bang HÀNG HÓA
create table hang_hoa
(
	ma_hh	varchar(10),
	ten_hh	nvarchar(200) not null,
	dvt	nvarchar(50) not null,
	dongia	float not null,
	mamau	varchar(10) not null,
	sl_tonkho int not null, 
	tinhtrang_tonkho char (1) not null

	constraint pk_hang_hoa primary key(ma_hh)
)
go
--Tao bang KHÁCH HÀNG
create table khach_hang
(
	ma_kh varchar(10),
	ten_kh	nvarchar(150) not null,
	diachi	nvarchar(150) not null,
	sdt	varchar(15) not null,

	constraint pk_khach_hang primary key(ma_kh)
)
go
--tao bang BÁN HÀNG
create table ban_hang
(
	ma_dbh	varchar(20),
	ma_kh	varchar(10),
	ngay_bh	date,
	tongtien float,
	tinhtrang_thanhtoan char(1) 

	constraint pk_ban_hang primary key(ma_dbh),
	constraint fk_bh_kh foreign key (ma_kh) references khach_hang(ma_kh)
)
go
--tao bang CHI TIẾT BÁN HÀNG
create table chitiet_banhang
(
	ma_dbh	varchar(20),
	ma_hh varchar(10),
	sl	int not null ,
	thanhtien float,

	constraint chk_sl check(sl>0),
	constraint chk_thanhtien check(thanhtien>=0),
	constraint pk_ctbh primary key(ma_dbh,ma_hh),
	constraint fk_ctbh_dbh foreign key (ma_dbh) references ban_hang(ma_dbh),
	constraint fk_ctbh_hh foreign key (ma_hh) references hang_hoa(ma_hh)
)
go 
-- SCRIPT MODULE Xây dựng các module tạo dữ liệu dump cho các bảng trong cơ sở dữ liệu. Mỗi bảng ít nhất 1000 dòng dữ liệu
--1.BẢNG khach_hang:
create or alter proc spKhachHang
as
begin
	declare @i int = 1

	-- tạo danh sách họ tạm thời
	declare @ho table (ho nvarchar(50))		
	insert into @ho values (N'Nguyễn'), (N'Trần'), (N'Lê'), (N'Phạm'), (N'Vũ'), (N'Hoàng'), (N'Phan'), (N'Võ'), (N'Đặng'), (N'Bùi')

	-- tạo danh sách tên đệm tạm thời
	declare @ten_dem table (ten_dem nvarchar(50))			
	insert into @ten_dem values (N'Văn'), (N'Thị'), (N'Hồng'), (N'Minh'), (N'Xuân'), (N'Quang'), (N'Công'), (N'Tuấn'), (N'Thanh'), (N'Phương')
	
	-- tạo danh sách tên tạm thời
	declare @ten table (ten nvarchar(50))						
	insert into @ten values (N'Anh'), (N'Bình'), (N'Châu'), (N'Dũng'), (N'Dung'), (N'Hà'), (N'Hùng'), (N'Khánh'), (N'Lan'), (N'Long'), 
							(N'Mai'), (N'Nam'), (N'Ngân'), (N'Phú'), (N'Quý'), (N'Sơn'), (N'Thảo'), (N'Trang'), (N'Tuấn'), (N'Việt')

	while @i <= 1000
	begin
		declare @ma_kh varchar(10),
				@ten_kh nvarchar(150),
				@diachi nvarchar(150),
				@sdt varchar(15),
				@ho_ngau_nhien nvarchar(50),
				@ten_dem_ngau_nhien nvarchar(50),
				@ten_ngau_nhien nvarchar(50),
				@so_nha nvarchar(10)

		set @ma_kh = 'KH' + right('0000' + cast(@i as varchar(10)), 4)				-- tạo mã khách hàng dạng KH0001, KH0002,...
		select top 1 @ho_ngau_nhien = ho from @ho order by newid()					-- tạo họ ngẫu nhiên
		select top 1 @ten_dem_ngau_nhien = ten_dem from @ten_dem order by newid()	-- tạo tên đệm ngẫu nhiên
		select top 1 @ten_ngau_nhien = ten from @ten order by newid()				-- tạo tên ngẫu nhiên
		set @ten_kh = @ho_ngau_nhien + N' ' + @ten_dem_ngau_nhien + N' ' + @ten_ngau_nhien				-- kết hợp để tạo tên đầy đủ

		-- tạo số nhà ngẫu nhiên từ 1 đến 999
		set @so_nha = cast(abs(checksum(newid())) % 999 + 1 as nvarchar(10))

		-- tạo địa chỉ với số nhà ngẫu nhiên và giữ nguyên các phần còn lại
		set @diachi = case (abs(checksum(newid())) % 6 + 1)
						when 1 then @so_nha + N' Lê Duẩn, Hải Châu, Đà Nẵng'
						when 2 then @so_nha + N' Phan Châu Trinh, Hải Châu, Đà Nẵng'
						when 3 then @so_nha + N' Hùng Vương, Thanh Khê, Đà Nẵng'
						when 4 then @so_nha + N' Điện Biên Phủ, Thanh Khê, Đà Nẵng'
						when 5 then @so_nha + N' Nguyễn Văn Linh, Hải Châu, Đà Nẵng'
						else @so_nha + N' Hoàng Diệu, Hải Châu, Đà Nẵng'
					end

		set @sdt = '09' + cast(abs(checksum(newid())) % 90000000 + 10000000 as varchar(10))				-- tạo số điện thoại ngẫu nhiên

		insert into khach_hang (ma_kh, ten_kh, diachi, sdt)
		values (@ma_kh, @ten_kh, @diachi, @sdt)

		if @@rowcount <= 0
			begin
				print N'Lỗi khi thêm khách hàng'
				return 
			end
		-- tăng biến đếm
		set @i = @i + 1
	end
end

EXEC spKhachHang
select * from khach_hang
delete from khach_hang
--2. BẢNG hang_hoa
create or alter procedure spHangHoa
as
begin
    declare @i int, 
            @ten_hh nvarchar(200),
			@dvt nvarchar(50),
			@dongia float,
			@mamau nvarchar(100),
			@ma_hh varchar(10),
			@so_luong int = 1000,
			@so_hang_hien_co int,
			@sl_tonkho int,
			@tinhtrang_tonkho char(1)

    -- kiểm tra số lượng bản ghi đã tồn tại trong bảng hang_hoa
    select @so_hang_hien_co = count(*) from hang_hoa

    -- đặt biến @i bắt đầu từ số lượng hàng hiện có + 1
    set @i = @so_hang_hien_co + 1

    -- tạo bảng tạm chứa các đơn vị tính và mặt hàng mẫu
    declare @MatHang table (ten_hh nvarchar(200), dvt nvarchar(50), mamau nvarchar(100))
    
    -- thêm các thông tin mặt hàng mẫu
    insert into @MatHang (ten_hh, dvt, mamau)
    values
    (N'màu nước', N'chai', 'trang'),
    (N'màu acrylic', N'chai', 'do'),
    (N'màu dầu', N'hộp', 'xanhbien'),
    (N'màu bột', N'túi', 'xanhla'),
    (N'bột màu pigment', N'kg', 'vang'),
    (N'màu vẽ trên kính', N'chai', 'hong'),
    (N'màu vẽ trên vải', N'lọ', 'nau'),
    (N'màu vẽ trên gốm', N'bộ', 'tim'),
    (N'màu xịt', N'chai', N'cam'),
    (N'màu nước ép', N'thùng', 'xam')

    -- vòng lặp tạo dữ liệu
    while @i <= (@so_hang_hien_co + @so_luong)
    begin
        set @ma_hh = 'hh' + right('000' + cast(@i as varchar(10)), 3)						-- sinh mã hàng hóa
        select top 1 @ten_hh = left(ten_hh, 200),											-- lấy ngẫu nhiên mặt hàng từ bảng tạm
                      @dvt = left(dvt, 50),       
                      @mamau = left(mamau, 10)    
        from @MatHang
        order by newid()
        set @dongia = round((20000 + (cast(abs(checksum(newid())) % 980000 as float))), -3)	-- sinh giá ngẫu nhiên từ 20K-> 1000K với các mức giá ưu tiên
        set @sl_tonkho = abs(checksum(newid())) % 551 + 49									-- sinh số lượng ngẫu nhiên từ 49 đến 599												
        set @tinhtrang_tonkho = case when @sl_tonkho > 0 then '1' else '0' end				-- gán tình trạng tồn kho

        -- chèn dữ liệu vào bảng hang_hoa
        insert into hang_hoa (ma_hh, ten_hh, dvt, dongia, mamau, sl_tonkho, tinhtrang_tonkho)
        values (@ma_hh, @ten_hh, @dvt, @dongia, @mamau, @sl_tonkho, @tinhtrang_tonkho)

        -- kiểm tra xem dữ liệu đã được chèn thành công chưa
        if @@rowcount <= 0
        begin
            print N'Lỗi khi thêm hàng hóa'
            return;
        end

        -- tăng chỉ số
        set @i = @i + 1
    end
end

exec spHangHoa
select * from hang_hoa
delete from hang_hoa
--3.BANG ban_hang va chitiet_banhang
create or alter procedure spBanHang_ChiTietBanHang
as
begin
    declare @i int = 1
    declare @ma_dbh varchar(20),
            @ma_kh varchar(10),
            @ngay_bh date,
            @tongtien float,
            @tinhtrang_thanhtoan char(1),
            @ma_hh varchar(10),
            @sl int,
            @thanhtien float

    while @i <= 1000
    begin
		--liên quan tới bảng bán hàng
        set @ma_dbh = 'dbh' + right('0000' + cast(@i as varchar(10)), 4)						        -- Tạo mã đơn bán hàng dạng dbhxxxx
        select top 1 @ma_kh = ma_kh from khach_hang order by newid()									-- makh ngẫu nhiên từ bảng khach_hang
        set @ngay_bh = dateadd(day, -abs(checksum(newid()) % 365), getdate())					        -- ngày ngẫu nhiên từ ngày hiện tại trở về trước 365 ngày
        set @tongtien = 0																				-- Khởi tạo tổng tiền
        set @tinhtrang_thanhtoan = case when abs(checksum(newid())) % 2 = 0 then '0' else '1' end	    -- Gán tình trạng thanh toán ngẫu nhiên

        -- Chèn dữ liệu vào bảng ban_hang
        insert into ban_hang (ma_dbh, ma_kh, ngay_bh, tongtien, tinhtrang_thanhtoan)
        values (@ma_dbh, @ma_kh, @ngay_bh, @tongtien, @tinhtrang_thanhtoan)

        -- Kiểm tra xem dữ liệu có được chèn thành công không
        if @@ROWCOUNT = 0
        begin
            print N'Lỗi khi thêm đơn hàng!'
            return
        end

		-- bảng chi tiết bán hàng
        -- Tạo 1 đến 5 mục cho từng đơn hàng
        declare @num_items int = abs(checksum(newid())) % 5 + 1  -- Số lượng mục ngẫu nhiên từ 1 đến 5
        declare @item_index int = 1
        while @item_index <= @num_items
        begin
            select top 1 @ma_hh = ma_hh from hang_hoa order by newid()									-- Chọn ngẫu nhiên mahh từ bảng hang_hoa
            set @sl = abs(checksum(newid())) % 100 + 1												    -- slhh ngẫu nhiên từ 1 đến 100
            select @thanhtien = @sl*dongia from hang_hoa where ma_hh = @ma_hh						    -- Tính thành tiền cho từng hàng hóa

            -- Chèn dữ liệu vào bảng chitiet_banhang
            insert into chitiet_banhang (ma_dbh, ma_hh, sl, thanhtien)
            values (@ma_dbh, @ma_hh, @sl, @thanhtien)

            -- Kiểm tra xem chi tiết đơn hàng có được chèn thành công không
            if @@ROWCOUNT = 0
            begin
                print N'Lỗi khi thêm chi tiết đơn hàng!'
                return
            end

            -- Cộng dồn tổng tiền cho đơn hàng
            set @tongtien = @tongtien + @thanhtien

            -- Tăng chỉ số
            set @item_index = @item_index + 1
        end

        -- Cập nhật lại tổng tiền cho bảng ban_hang
        update ban_hang
        set tongtien = @tongtien
        where ma_dbh = @ma_dbh

        -- Kiểm tra xem tổng tiền có được cập nhật thành công không
        if @@ROWCOUNT = 0
        begin
            print N'Lỗi khi cập nhật tổng tiền cho đơn hàng!'
            return
        end

        -- Tăng chỉ số cho đơn hàng
        set @i = @i + 1
    end
end

exec spBanHang_ChiTietBanHang


select * from ban_hang
select * from chitiet_banhang
delete from ban_hang

select *
from ban_hang
where ma_dbh='dbh0002'

select sum(thanhtien)
from chitiet_banhang
where ma_dbh='dbh0002'
--MODULE Xây dựng ít nhất 10 module trong cơ sở dữ liệu
--để phục vụ các thao tác xử lý dữ liệu (kiểm tra sự hợp lệ của dữ liệu, xử lý các thao tác nghiệp vụ phức hợp,...):
--1.MODULE TỰ ĐỘNG KIỂM TRA VÀ CẬP NHẬT DỮ LIỆU Ở CÁC BẢNG LIÊN QUAN (BÁN HÀNG, HÀNG HÓA) KHI THÊM MỚI DỮ LIỆU Ở BẢNG CHI TIẾT BÁN HÀNG
create or alter trigger trg_chitiet_banhang_insert
on chitiet_banhang
after insert
as
begin
    -- khai báo các biến
    declare @ma_dbh varchar(20),
            @ma_hh varchar(10),
            @sl int,
            @tinhtrang_tonkho char(1),
            @sl_tonkho int,
            @dongia float,
            @thanhtien float

    -- bước 1: lấy ma_dbh, ma_hh, sl từ bảng inserted
    select @ma_dbh = ma_dbh, 
           @ma_hh = ma_hh, 
           @sl = sl
    from inserted

    -- bước 2: kiểm tra mã đơn bán hàng có tồn tại trong bảng ban_hang hay không
    if not exists (select 1 from ban_hang where ma_dbh = @ma_dbh)
    begin
        print N'!!! vui lòng tạo đơn bán hàng trước khi nhập dữ liệu !!!'
        rollback transaction
        return
    end

    -- bước 3: kiểm tra mã hàng hóa có tồn tại trong bảng hang_hoa hay không
    if not exists (select 1 from hang_hoa where ma_hh = @ma_hh)
    begin
        print N'!!! không tồn tại hàng hóa !!!'
        rollback transaction
        return
    end

    -- lấy các thông tin tinhtrang_tonkho, sl_tonkho, và dongia từ bảng hang_hoa nếu mã hàng hóa tồn tại
    select @tinhtrang_tonkho = tinhtrang_tonkho, 
           @sl_tonkho = sl_tonkho, 
           @dongia = dongia
    from hang_hoa 
    where ma_hh = @ma_hh

    -- kiểm tra tình trạng tồn kho
    if @tinhtrang_tonkho = '0'
    begin
        print N'!!! hết hàng !!!'
        rollback transaction
        return
    end

    -- bước 4: kiểm tra số lượng hàng hóa nhập vào
    if @sl < 0
    begin
        print N'!!! vui lòng nhập số lượng > 0 !!!'
        rollback transaction
        return
    end
    else if @sl > @sl_tonkho
    begin
        print N'!!! hàng hóa không đủ. vui lòng hỏi khách hàng điều chỉnh số lượng nếu được !!!!'
        rollback transaction
        return
    end

    -- bước 5: cập nhật lại sl_tonkho
    set @sl_tonkho = @sl_tonkho - @sl

    -- cập nhật lại số lượng tồn kho
    update hang_hoa
    set sl_tonkho = @sl_tonkho
    where ma_hh = @ma_hh

    -- kiểm tra cập nhật tồn kho
    if @@rowcount = 0
    begin
        print N'!!!CẬP NHẬT TỒN KHO THẤT BẠI!!!'
        rollback transaction
        return
    end

    -- thông báo khi hàng hóa sắp hết
    if @sl_tonkho < 100
    begin
        print N'!!! hàng hóa sắp hết. vui lòng nhập hàng !!!'
    end

    -- nếu sl_tonkho = 0, cập nhật tình trạng hàng hóa
    if @sl_tonkho = 0
    begin
        update hang_hoa
        set tinhtrang_tonkho = '0'
        where ma_hh = @ma_hh
        print N'!!! hết hàng !!! NHẬP HÀNG MỚI NẾU CẦN'
    end

    -- bước 6: cập nhật thành tiền
    set @thanhtien = @sl * @dongia

    -- cập nhật thành tiền vào bảng chitiet_banhang
    update chitiet_banhang
    set thanhtien = @thanhtien
    where ma_dbh = @ma_dbh and ma_hh = @ma_hh and sl = @sl

    -- kiểm tra cập nhật thành tiền có thành công không
    if @@rowcount = 0
    begin
        print N'!!! CẬP NHẬT THÀNH TIỀN THẤT BẠI!!!'
        rollback transaction
        return
    end

    -- bước 7: cập nhật tổng tiền vào bảng ban_hang
    update ban_hang 
    set tongtien = tongtien + @thanhtien 
    where ma_dbh = @ma_dbh

    -- kiểm tra cập nhật tổng tiền có thành công không
    if @@rowcount = 0
    begin
        print N'!!! CẬP NHẬT TỔNG TIỀN THẤT BẠI !!!'
        rollback transaction
        return
    end
end
--2.	MODULE TỰ ĐỘNG CẬP NHẬT DỮ LIỆU Ở CÁC BẢNG LIÊN QUAN (BÁN HÀNG, HÀNG HÓA) KHI XÓA DỮ LIỆU Ở BẢNG CHI TIẾT BÁN HÀNG
create or alter trigger trg_chitiet_banhang_delete
on chitiet_banhang
after delete
as
begin
    -- bước 1: khai báo các biến
    declare @ma_dbh varchar(20),
            @ma_hh varchar(10),
            @sl int,
            @thanhtien float,
            @tongtien float,
            @sl_tonkho int
    -- lấy giá trị từ bảng deleted
    select 
        @ma_dbh = ma_dbh,
        @ma_hh = ma_hh,
        @sl = sl,
        @thanhtien = thanhtien
    from deleted
    -- bước 2: cập nhật lại tổng tiền ở bảng ban_hang
    update ban_hang
    set tongtien = tongtien - @thanhtien
    where ma_dbh = @ma_dbh

    -- bước 3: lấy số lượng tồn kho từ bảng hang_hoa
    select @sl_tonkho = sl_tonkho
    from hang_hoa
    where ma_hh = @ma_hh

    -- bước 4: cập nhật lại bảng hang_hoa
    -- a. cập nhật số lượng tồn kho
	set @sl_tonkho = @sl_tonkho + @sl 
    update hang_hoa
    set sl_tonkho = @sl_tonkho,
        tinhtrang_tonkho = case when @sl_tonkho > 0 then '1' else tinhtrang_tonkho end
    where ma_hh = @ma_hh

    -- b. kiểm tra số lượng tồn kho
    if (@sl_tonkho  < 100)
    begin
        print N'!!! hàng hóa sắp hết. vui lòng chú ý nhập hàng mới!!!'
    end

end
--3.	MODULE TỰ ĐỘNG KIỂM TRA DỮ LIỆU KHI NHẬP VÀO BẢNG HÀNG HÓA
create or alter trigger trg_hanghoa_insert
on hang_hoa
after insert
as
begin
    -- bước 1: khai báo các biến
    declare @ma_hh varchar(20),
            @dongia float,
            @sl_tonkho int,
            @tinhtrang_tonkho char(1)

    -- lấy giá trị từ bảng inserted
    select 
        @ma_hh = ma_hh,
        @dongia = dongia,
        @sl_tonkho = sl_tonkho,
        @tinhtrang_tonkho = tinhtrang_tonkho
    from inserted

    -- bước 2: kiểm tra đơn giá nhập vào
    if @dongia <= 0
    begin
        print N'Đơn giá phải > 0!!!'
        rollback transaction
        return
    end

    -- bước 3: kiểm tra số lượng tồn kho
    if @sl_tonkho < 0
    begin
        print N'Số lượng không hợp lệ!!!'
        rollback transaction
        return
    end

    -- bước 4: kiểm tra và cập nhật tình trạng tồn kho nếu không khớp
    if @sl_tonkho = 0 and @tinhtrang_tonkho <> '0'
    begin
        update hang_hoa
        set tinhtrang_tonkho = '0'
        where ma_hh = @ma_hh
        print N'Tình trạng tồn kho đã được cập nhật về "hết hàng"'
    end
    else if @sl_tonkho > 0 and @tinhtrang_tonkho <> '1'
    begin
        update hang_hoa
        set tinhtrang_tonkho = '1'
        where ma_hh = @ma_hh
        print N'Tình trạng tồn kho đã được cập nhật về "còn hàng"'
    end
end
--4.	MODULE TÍNH TỔNG DOANH THU VÀ CÔNG NỢ THEO KHÁCH HÀNG TRONG MỘT KHOẢNG THỜI GIAN NHẤT ĐỊNH
create or alter proc  spTinhDoanhThu_CongNo
    @startdate nvarchar(10),  
    @enddate nvarchar(10),    
    @doanhthu float output,    --doanh thu
    @congno float output,      --công nợ
    @slDBH int output,         --slDBH chưa thanh toán
    @TongKHNo int output,      --slKHchưa thanh toán
    @tbNo float output          --tbinh nợ trên KH
as
begin
    declare @ngaybatdau date,  
            @ngayketthuc date   

    begin try
        set @ngaybatdau = cast(convert(date, @startdate, 103) as date)  --chuyển về kiểu date
        set @ngayketthuc = cast(convert(date, @enddate, 103) as date)    
    end try
    begin catch
        print N'dữ liệu nhập vào không phải là định dạng ngày hợp lệ'  
        return
    end catch

    -- Kiểm tra điều kiện ngày bắt đầu và kết thúc
    if @ngaybatdau >= @ngayketthuc or @ngayketthuc >= getdate()
    begin
		-- Thông báo lỗi nếu điều kiện không thỏa mãn
        print N'ngày bắt đầu phải nhỏ hơn ngày kết thúc và ngày kết thúc phải nhỏ hơn ngày hiện tại'  
        return
    end

    -- Tính tổng doanh thu trong khoảng thời gian
    select @doanhthu = sum(tongtien)
    from ban_hang 
    where ngay_bh between @ngaybatdau and @ngayketthuc

    -- Tính tổng công nợ trong khoảng thời gian
    select @congno = sum(tongtien)
    from ban_hang 
    where ngay_bh between @ngaybatdau and @ngayketthuc
          and tinhtrang_thanhtoan = '0'

    -- Tính số lượng đơn hàng chưa thanh toán
    select @slDBH = count(*)
    from ban_hang 
    where ngay_bh between @ngaybatdau and @ngayketthuc
          and tinhtrang_thanhtoan = '0'

    -- Tính số lượng khách hàng chưa thanh toán
    select @TongKHNo = count(distinct ban_hang.ma_kh)
    from ban_hang 
    where ngay_bh between @ngaybatdau and @ngayketthuc
          and tinhtrang_thanhtoan = '0'

    -- Tính trung bình nợ trên mỗi khách hàng
    if @TongKHNo > 0
    begin
        set @tbNo = @congno / @TongKHNo
    end
    else
    begin
        set @tbNo = 0  -- Nếu không có khách hàng, trung bình nợ sẽ là 0
    end

	-- Chia cho 1.000.000 để hiển thị đơn vị triệu
    set @doanhthu = @doanhthu / 1000000
    set @congno = @congno / 1000000
    set @tbNo = @tbNo / 1000000

    -- In kết quả
    print N'doanh thu: ' + cast(@doanhthu as nvarchar(20)) + N' triệu'					-- In doanh thu
    print N'công nợ: ' + cast(@congno as nvarchar(20)) + N' triệu'						-- In công nợ
    print N'số lượng đơn hàng chưa thanh toán: ' + cast(@slDBH as nvarchar(20))			-- In slDBH chưa thanh toán
    print N'số lượng khách hàng chưa thanh toán hóa đơn: ' + cast(@TongKHNo as nvarchar(20))		-- In slKH chưa thanh toán
    print N'trung bình nợ trên mỗi khách hàng: ' + cast(@tbNo as nvarchar(20)) + N' triệu'			-- In trung bình nợ
end

declare @DT float,  
		@No float,        
        @tongDonNo int,   
        @tongKh int,      
        @tb float         

-- Gọi thủ tục và truyền vào các tham số, đồng thời nhận giá trị đầu ra
exec spTinhDoanhThu_CongNo 
    '29/12/2020',   
    '29/12/2023',      
    @DT output,       
    @No output,         
    @tongDonNo output,   
    @tongKh output,   
 @tb output
--5.	MODULE KIỂM TRA DỮ LIỆU KHI NHẬP VÀO BẢNG BÁN HÀNG
create trigger trg_kiemtradulieu_BanHang
on ban_hang
after insert
as
begin
    declare @ngaybh date,												--kbao biến để lưu gtri từ bảng inserted
            @tongtien float, 
            @madbh nvarchar(20)

    select @ngaybh = ngay_bh, @tongtien = tongtien, @madbh = ma_dbh		--lấy giá trị từ bảng inserted
    from inserted

    -- bước 1: kiểm tra ngày bán hàng
    if @ngaybh > getdate()
    begin
        print N'!!! ngày bán hàng không phù hợp! vui lòng nhập lại (ngày bán hàng không được vượt quá ngày hiện tại)'
        rollback transaction 
        return
    end

    -- bước 2: kiểm tra tổng tiền
    if @tongtien < 0
    begin
        print N'!!! dữ liệu không hợp lý (phải >= 0)'
        rollback transaction 
        return
    end

    -- bước 3: kiểm tra tổng tiền ở bảng bán hàng so với bảng chi tiết bán hàng
    declare @count int, 
            @sumthanhtien float										 -- khai báo biến để lưu tổng thành tiền

    select @count = count(*) from chitiet_banhang where ma_dbh = @madbh

    if @count = 0													-- không có chi tiết bán hàng cho mã đơn này -> tổng tiền cho madbh này = 0
    begin
        if @tongtien <> 0				
        begin
            update ban_hang
            set tongtien = 0
            where ma_dbh = @madbh
        end
    end

    else if @count > 0												-- tồn tại mã đơn bán hàng ở bảng chi tiết bán hàng
    begin
        select @sumthanhtien = sum(thanhtien)						-- tính tổng các thành tiền theo mã đơn bán hàng
        from chitiet_banhang 
        where ma_dbh = @madbh

        if @tongtien <> @sumthanhtien								-- so sánh tổng các thành tiền theo mã đơn với tổng tiền được nhập
        begin
            update ban_hang
            set tongtien = @sumthanhtien
            where ma_dbh = @madbh
        end
    end

    -- bước 4: kiểm tra @@rowcount
    if @@rowcount > 0
    begin
        print N'cập nhật thành công tổng tiền cho đơn hàng ' + @madbh
    end
    else
    begin
        print N'không có thay đổi nào được thực hiện cho đơn hàng ' + @madbh
    end
end
--6.	MODULE TỰ ĐỘNG KIỂM TRA KHÁCH HÀNG ĐÃ TỒN TẠI TRONG CSDL KHI THÊM KHÁCH HÀNG QUA HỌ TÊN VÀ SỐ ĐIỆN THOẠI
create or alter trigger tInsertCustomer
on khach_hang
after insert
as
begin
	-- khai báo biến
	declare @HotenKH nvarchar(150), @SDT varchar(15)
	-- bước 1: lấy dữ liệu họ tên, số điện thoại từ bảng inserted
	select @HotenKH = ten_kh,
			@SDT = sdt 
	from inserted
	-- bước 2: kiểm tra sự tồn tại của họ tên, số điện thoại trong csdl
	if (select count(*) from khach_hang where ten_kh = @HotenKH and sdt = @SDT) >=2
	begin
		print N'!!! Khách hàng đã tồn tại !!!'
		rollback
	end
end
--7.	MODULE TẠO MÃ KHÁCH HÀNG MỚI TỰ ĐỘNG
create or alter function fNewCustomerID()
returns varchar(10)
as
begin
	--khai báo biến
	declare @NewCustomerID varchar(10),
			@ID_number_part int,
			@MaxCustomerID varchar(10)
	-- Bước 1: lấy mã khách hàng mới nhất trong bảng khách hàng
	select @MaxCustomerID = max(ma_kh) from khach_hang
	-- Bước 2: lấy ra phần số trong mã khách hàng mới nhất
	set @ID_number_part = Cast(SUBSTRING(@MaxCustomerID, 3, 4) as int)
	-- Bước 3: cộng thêm 1 đơn vị vào phần số
	set @ID_number_part += 1
	-- Bước 4: Tạo mã khách hàng mới
	set @NewCustomerID = 'KH' + RIGHT('0000' + CAST(@ID_number_part as varchar(4)), 4)

	return @NewCustomerID
end

select dbo.fNewCustomerID()
--8.	MODULE TẠO MÃ HÀNG HÓA MỚI TỰ ĐỘNG
create or alter function fNewProductID()
returns varchar(10)
as
begin
	--khai báo biến
	declare @NewProductID varchar(10),
			@ID_number_part int,
			@MaxProductID varchar(10)
	-- Bước 1: lấy mã hàng hóa mới nhất trong bảng khách hàng
	select @MaxProductID = max(ma_hh) from hang_hoa
	-- Bước 2: lấy ra phần số trong mã hàng hóa mới nhất
	set @ID_number_part = Cast(SUBSTRING(@MaxProductID, 3, 3) as int)
	-- Bước 3: cộng thêm 1 đơn vị vào phần số
	set @ID_number_part += 1
	-- Bước 4: Tạo mã khách hàng mới
	set @NewProductID = 'hh' + RIGHT('0000' + CAST(@ID_number_part as varchar(4)), 3)
	
	return @NewProductID
end

select dbo.fNewProductID
--9.	MODULE TẠO MÃ ĐƠN BÁN HÀNG MỚI TỰ ĐỘNG
create or alter function fNewDBH_ID()
returns varchar(10)
as
begin
	-- khai báo biến
	declare @NewDBH_ID varchar(10),
			@ID_number_part int,
			@MaxDBH_ID varchar(10)
	-- Bước 1: lấy mã đơn bán hàng mới nhất trong bảng khách hàng
	select @NewDBH_ID = max(ma_dbh) from ban_hang
	-- Bước 2: lấy ra phần số trong mã đơn bán hàng mới nhất
	set @ID_number_part = Cast(SUBSTRING(@MaxDBH_ID, 3, 4) as int)
	-- Bước 3: cộng thêm 1 đơn vị vào phần số
	set @ID_number_part += 1
	-- Bước 4: Tạo mã đơn bán hàng mới
	set @NewDBH_ID = 'dbh' + RIGHT('0000' + CAST(@ID_number_part as varchar(4)), 4)

	return @NewDBH_ID
end

select dbo.fNewDBH_ID
--10.	MODULE ĐÁNH GIÁ KHẢ NĂNG MUA CỦA KHÁCH HÀNG DỰA TRÊN TỔNG SỐ TIỀN MUA HÀNG TRONG 1 THÁNG TRONG 1 NĂM NÀO ĐÓ
CREATE OR ALTER PROCEDURE spDanhGiaKhaNangMua
    @month INT,        -- Tháng cần đánh giá
    @year INT          -- Năm cần đánh giá
AS
BEGIN
    -- Bước 1: Tạo bảng tạm chứa thông tin đánh giá khả năng mua của khách hàng
    DECLARE @danhgia TABLE (
        ma_kh VARCHAR(10),
        ten_kh NVARCHAR(150),
        tongtien FLOAT,
        danhgia NVARCHAR(50)
    );

    -- Bước 2: Tính tổng tiền của mỗi khách hàng trong tháng và năm được cung cấp
    INSERT INTO @danhgia (ma_kh, ten_kh, tongtien)
    SELECT kh.ma_kh, kh.ten_kh, SUM(bh.tongtien)
    FROM khach_hang kh
    JOIN ban_hang bh ON kh.ma_kh = bh.ma_kh
    WHERE MONTH(bh.ngay_bh) = @month AND YEAR(bh.ngay_bh) = @year
    GROUP BY kh.ma_kh, kh.ten_kh;

    -- Bước 3: Cập nhật đánh giá khả năng mua dựa trên tổng số tiền
    UPDATE @danhgia
    SET danhgia = CASE 
                    WHEN tongtien >= 10000000 THEN N'Cao'
                    WHEN tongtien >= 5000000  THEN N'Trung bình'
                    ELSE N'Thấp'
                  END;

    -- Bước 4: Trả kết quả
    SELECT ma_kh, ten_kh, tongtien, danhgia
    FROM @danhgia
    ORDER BY tongtien DESC;
END;

--TEST THỬ
EXEC spDanhGiaKhaNangMua @month = 7, @year = 2025;
-- KIỂM TRA DATA
SELECT * 
FROM ban_hang
WHERE MONTH(ngay_bh) = 7 AND YEAR(ngay_bh) = 2025;
--11.	MODULE TỰ ĐỘNG CHIẾT KHẤU CHO KHÁCH HÀNG DỰA TRÊN TỔNG TIỀN MUA HÀNG CỦA KHÁCH HÀNG TRONG THÁNG ĐÓ
CREATE OR ALTER TRIGGER trgChietKhauChoKhachHang
ON ban_hang
AFTER INSERT
AS
BEGIN
    DECLARE @ma_kh VARCHAR(10);
    DECLARE @ma_dbh VARCHAR(20);
    DECLARE @tongtien_thang FLOAT;
    DECLARE @chietkhau FLOAT;
    DECLARE @tongtien_goc FLOAT;
    DECLARE @month INT;
    DECLARE @year INT;

    -- Lấy mã khách hàng và mã đơn bán hàng từ bảng được chèn vào
    SELECT @ma_kh = i.ma_kh, @ma_dbh = i.ma_dbh, @tongtien_goc = i.tongtien, 
           @month = MONTH(i.ngay_bh), @year = YEAR(i.ngay_bh)
    FROM inserted i;

    -- Tính tổng số tiền mà khách hàng đã chi tiêu trong tháng đó
    SELECT @tongtien_thang = SUM(tongtien)
    FROM ban_hang
    WHERE ma_kh = @ma_kh AND MONTH(ngay_bh) = @month AND YEAR(ngay_bh) = @year;

    -- Tính toán mức chiết khấu dựa trên tổng số tiền của khách hàng trong tháng đó
    IF @tongtien_thang >= 10000000
        SET @chietkhau = 0.10; -- Chiết khấu 10%
    ELSE IF @tongtien_thang >= 5000000
        SET @chietkhau = 0.05; -- Chiết khấu 5%
    ELSE
        SET @chietkhau = 0; -- Không chiết khấu

    -- Nếu có chiết khấu thì tính toán lại tổng tiền sau khi chiết khấu
    IF @chietkhau > 0
    BEGIN
        -- Tính tổng tiền sau khi chiết khấu
        DECLARE @tongtien_sau_ck FLOAT;
        SET @tongtien_sau_ck = @tongtien_goc * (1 - @chietkhau);

        -- Cập nhật lại tổng tiền của đơn hàng trong bảng ban_hang
        UPDATE ban_hang
        SET tongtien = @tongtien_sau_ck
        WHERE ma_dbh = @ma_dbh;

        -- In thông báo về việc chiết khấu (nếu cần)
        PRINT N'Khách hàng ' + @ma_kh + N' đã được áp dụng chiết khấu ' + CAST(@chietkhau * 100 AS VARCHAR(5)) + N'% cho đơn hàng ' + @ma_dbh;
    END
    ELSE
    BEGIN
        PRINT N'Khách hàng ' + @ma_kh + N' không được áp dụng chiết khấu cho đơn hàng ' + @ma_dbh;
    END
END;

-- Thêm đơn hàng mới
INSERT INTO ban_hang (ma_dbh, ma_kh, ngay_bh, tongtien, tinhtrang_thanhtoan)
VALUES ('DBH1001', 'KH0001', GETDATE(), 5000000, '0');

-- Kiểm tra lại dữ liệu
SELECT * FROM ban_hang WHERE ma_dbh = 'DBH1001';

-- Chừ muốn xoá:
DELETE FROM ban_hang
WHERE ma_dbh = 'DBH1001';
--12.	MODULE TẠO "COMBO KHUYẾN MÃI" DỰA TRÊN SẢN PHẨM MUA NHIỀU NHẤT VÀ SẢN PHẨM MUA ÍT NHẤT MỖI THÁNG TRONG NĂM NÀO ĐÓ
CREATE OR ALTER PROCEDURE spTaoComboKhuyenMaiTheoThang
    @year INT,      -- Năm cần lọc
    @month INT      -- Tháng cần lọc
AS
BEGIN
    DECLARE @ma_hh_nhieu VARCHAR(10); -- Sản phẩm mua nhiều nhất
    DECLARE @ma_hh_it VARCHAR(10);    -- Sản phẩm mua ít nhất
    DECLARE @ten_hh_nhieu NVARCHAR(200); -- Tên sản phẩm nhiều nhất
    DECLARE @ten_hh_it NVARCHAR(200);    -- Tên sản phẩm ít nhất

    -- Lấy tổng số lượng mua nhiều nhất trong tháng được chỉ định
    DECLARE @sl_nhieu INT;
    SELECT @sl_nhieu = MAX(tongsl)
    FROM (
        SELECT ctbh.ma_hh, SUM(ctbh.sl) AS tongsl
        FROM chitiet_banhang ctbh
        JOIN ban_hang bh ON ctbh.ma_dbh = bh.ma_dbh
        WHERE YEAR(bh.ngay_bh) = @year AND MONTH(bh.ngay_bh) = @month
        GROUP BY ctbh.ma_hh
    ) AS subquery;

    -- Lấy tổng số lượng mua ít nhất trong tháng được chỉ định
    DECLARE @sl_it INT;
    SELECT @sl_it = MIN(tongsl)
    FROM (
        SELECT ctbh.ma_hh, SUM(ctbh.sl) AS tongsl
        FROM chitiet_banhang ctbh
        JOIN ban_hang bh ON ctbh.ma_dbh = bh.ma_dbh
        WHERE YEAR(bh.ngay_bh) = @year AND MONTH(bh.ngay_bh) = @month
        GROUP BY ctbh.ma_hh
    ) AS subquery;

    -- Lấy tất cả sản phẩm có tổng số lượng bán bằng @sl_nhieu (mua nhiều nhất)
    SELECT @ma_hh_nhieu = ma_hh
    FROM (
        SELECT ctbh.ma_hh, SUM(ctbh.sl) AS tongsl
        FROM chitiet_banhang ctbh
        JOIN ban_hang bh ON ctbh.ma_dbh = bh.ma_dbh
        WHERE YEAR(bh.ngay_bh) = @year AND MONTH(bh.ngay_bh) = @month
        GROUP BY ctbh.ma_hh
    ) AS subquery
    WHERE tongsl = @sl_nhieu;

    -- Lấy tất cả sản phẩm có tổng số lượng bán bằng @sl_it (mua ít nhất)
    SELECT @ma_hh_it = ma_hh
    FROM (
        SELECT ctbh.ma_hh, SUM(ctbh.sl) AS tongsl
        FROM chitiet_banhang ctbh
        JOIN ban_hang bh ON ctbh.ma_dbh = bh.ma_dbh
        WHERE YEAR(bh.ngay_bh) = @year AND MONTH(bh.ngay_bh) = @month
        GROUP BY ctbh.ma_hh
    ) AS subquery
    WHERE tongsl = @sl_it;

    -- Lấy tên của sản phẩm nhiều nhất
    SELECT @ten_hh_nhieu = ten_hh FROM hang_hoa WHERE ma_hh = @ma_hh_nhieu;

    -- Lấy tên của sản phẩm ít nhất
    SELECT @ten_hh_it = ten_hh FROM hang_hoa WHERE ma_hh = @ma_hh_it;

    -- Trả về kết quả combo
    SELECT 
        N'Sản phẩm bán nhiều nhất trong tháng ' + CAST(@month AS NVARCHAR) + N'/' + CAST(@year AS NVARCHAR) AS LoaiSanPham, 
        @ma_hh_nhieu AS MaSanPham, 
        @ten_hh_nhieu AS TenSanPham,
        @sl_nhieu AS SoLuong
    UNION ALL
    SELECT 
        N'Sản phẩm bán ít nhất trong tháng ' + CAST(@month AS NVARCHAR) + N'/' + CAST(@year AS NVARCHAR), 
        @ma_hh_it, 
        @ten_hh_it, 
        @sl_it;
END;
--TEST
EXEC spTaoComboKhuyenMaiTheoThang @year = 2025, @month = 7;
--13.	MODULE TỰ ĐỘNG TẠO ĐỀ XUẤT GIẢM GIÁ CHO SẢN PHẦM CÓ SỐ LƯỢNG TỒN KHO CAO
CREATE OR ALTER TRIGGER tgTuDongDeXuatGiamGia
ON hang_hoa
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @ma_hh VARCHAR(10);
    DECLARE @sl_ton_kho INT;
    DECLARE @ngay_de_xuat DATE = GETDATE(); -- Ngày hiện tại

    -- Kiểm tra từng sản phẩm được thêm hoặc cập nhật
    DECLARE cur CURSOR FOR
    SELECT ma_hh, sl_tonkho
    FROM inserted; -- Bảng tạm chứa các bản ghi vừa được thêm hoặc cập nhật

    OPEN cur;
    FETCH NEXT FROM cur INTO @ma_hh, @sl_ton_kho;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Nếu tồn kho lớn hơn hoặc bằng 100 mới đề xuất giảm giá
        IF @sl_ton_kho >= 100
        BEGIN
            DECLARE @giam_gia INT;

            -- Quyết định mức giảm giá dựa trên tồn kho
            IF @sl_ton_kho > 200
                SET @giam_gia = 10; -- Giảm giá 10%
            ELSE IF @sl_ton_kho BETWEEN 150 AND 200
                SET @giam_gia = 5; -- Giảm giá 5%
            ELSE 
                SET @giam_gia = 3; -- Giảm giá 3%

            -- In thông tin đề xuất giảm giá
            PRINT	N'Đề xuất giảm giá cho sản phẩm ' + @ma_hh + N': Giảm ' 
					+ CAST(@giam_gia AS VARCHAR(3)) + N'% vào ngày ' + CONVERT(VARCHAR, @ngay_de_xuat, 105);
        END
        ELSE
        BEGIN
            -- Nếu tồn kho dưới 100, không tạo đề xuất giảm giá
            PRINT N'Không đề xuất giảm giá cho sản phẩm ' + @ma_hh + N' vì tồn kho dưới 100.';
        END

        FETCH NEXT FROM cur INTO @ma_hh, @sl_ton_kho;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;

-- Chèn thêm:
INSERT INTO hang_hoa (ma_hh, ten_hh, dvt, dongia, mamau, sl_tonkho, tinhtrang_tonkho)
VALUES ('HH10000', N'Màu nước', 'Chai', 50000, 'Trang', 250, '1');

-- Cập nhật sản phẩm để tăng số lượng tồn kho
UPDATE hang_hoa
SET sl_tonkho = 100
WHERE ma_hh = 'HH10000';

--Xoá:
DELETE FROM HANG_HOA
WHERE MA_HH='HH10000'
--14.	MODULE TÌM SẢN PHẨM BÁN ĐƯỢC NHIỀU NHẤT THEO MÙA
CREATE OR ALTER PROCEDURE spSanPhamBanNhieuNhatTheoMua
    @mua NVARCHAR(50), -- Tham số để xác định mùa
    @nam INT -- Tham số để xác định năm
AS
BEGIN
    SET NOCOUNT ON; -- Giúp cải thiện hiệu suất

    DECLARE @max_sl INT;

    -- Tìm số lượng bán cao nhất trong mùa
    SELECT @max_sl = MAX(total_sl)
    FROM (
        SELECT h.ma_hh, SUM(ct.sl) AS total_sl
        FROM ban_hang b
        JOIN chitiet_banhang ct ON b.ma_dbh = ct.ma_dbh
        JOIN hang_hoa h ON ct.ma_hh = h.ma_hh
        WHERE (
            (@mua = N'Xuân' AND MONTH(b.ngay_bh) IN (3, 4, 5) AND YEAR(b.ngay_bh) = @nam) OR
            (@mua = N'Hạ' AND MONTH(b.ngay_bh) IN (6, 7, 8) AND YEAR(b.ngay_bh) = @nam) OR
            (@mua = N'Thu' AND MONTH(b.ngay_bh) IN (9, 10, 11) AND YEAR(b.ngay_bh) = @nam) OR
            (@mua = N'Đông' AND MONTH(b.ngay_bh) IN (12, 1, 2) AND YEAR(b.ngay_bh) = @nam)
        )
        GROUP BY h.ma_hh
    ) AS t;

    -- Kiểm tra xem có sản phẩm nào được bán hay không
    IF @max_sl IS NULL
    BEGIN
        PRINT N'Không có sản phẩm nào bán trong mùa và năm đã chọn.';
        RETURN;
    END

    -- Chọn danh sách sản phẩm có số lượng bán cao nhất
    SELECT h.ma_hh, h.ten_hh, SUM(ct.sl) AS total_sl
    FROM ban_hang b
    JOIN chitiet_banhang ct ON b.ma_dbh = ct.ma_dbh
    JOIN hang_hoa h ON ct.ma_hh = h.ma_hh
    WHERE (
        (@mua = N'Xuân' AND MONTH(b.ngay_bh) IN (3, 4, 5) AND YEAR(b.ngay_bh) = @nam) OR
        (@mua = N'Hạ' AND MONTH(b.ngay_bh) IN (6, 7, 8) AND YEAR(b.ngay_bh) = @nam) OR
        (@mua = N'Thu' AND MONTH(b.ngay_bh) IN (9, 10, 11) AND YEAR(b.ngay_bh) = @nam) OR
        (@mua = N'Đông' AND MONTH(b.ngay_bh) IN (12, 1, 2) AND YEAR(b.ngay_bh) = @nam)
    )
    GROUP BY h.ma_hh, h.ten_hh
    HAVING SUM(ct.sl) = @max_sl; -- Chỉ lấy sản phẩm có số lượng bán cao nhất
END;


EXEC spSanPhamBanNhieuNhatTheoMua @mua = N'Xuân', @nam = 2024;
--15.	MODULE KIỂM TRA SỐ LƯỢNG HÀNG HÓA KHÁCH HÀNG MUA KHÔNG VƯỢT QUA TỒN KHO
ON chitiet_banhang
AFTER INSERT
AS
BEGIN
    DECLARE @ma_hh VARCHAR(10);
    DECLARE @sl INT;
    DECLARE @sl_tonkho INT;

    -- Kiểm tra số lượng hàng hóa cho từng đơn hàng mới
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        JOIN hang_hoa h ON i.ma_hh = h.ma_hh
        WHERE i.sl > h.sl_tonkho
    )
    BEGIN
        -- Thông báo lỗi
        PRINT N'Tồn kho không đủ cho đơn hàng. Vui lòng kiểm tra lại số lượng hàng hóa.';
        ROLLBACK TRANSACTION; -- Ngăn chặn việc chèn bản ghi
    END
END 
--16.	MODULE THÔNG BÁO KHÔNG CHO PHÉP KHÁCH MUA HÀNG KHI KHÁCH HÀNG CÓ LỚN HƠN 10  ĐƠN HÀNG CHƯA THANH TOÁN
Script:
CREATE OR ALTER TRIGGER trgCheckCustomerOrders
ON chitiet_banhang
AFTER INSERT
AS
BEGIN
    DECLARE @ma_kh VARCHAR(10),
            @so_don_hang_chua_thanh_toan INT;

    -- Kiểm tra từng bản ghi trong bảng INSERTED
    WHILE EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        -- Lấy một bản ghi từ bảng INSERTED
        SELECT TOP 1 @ma_kh = ma_kh FROM chitiet_banhang WHERE ma_dbh IN (SELECT ma_dbh FROM INSERTED);

        -- Đếm số lượng đơn hàng chưa thanh toán của khách hàng
        SELECT @so_don_hang_chua_thanh_toan = COUNT(*) 
        FROM ban_hang 
        WHERE ma_kh = @ma_kh AND tinhtrang_thanhtoan = '0';  -- '0' là chưa thanh toán

        -- Kiểm tra nếu số lượng đơn hàng chưa thanh toán >= 10
        IF @so_don_hang_chua_thanh_toan >= 10
        BEGIN
            PRINT N'Khách hàng ' + @ma_kh + N' không thể mua hàng vì đã có ' + 
                  CAST(@so_don_hang_chua_thanh_toan AS NVARCHAR(10)) + N' đơn hàng chưa thanh toán.';
            ROLLBACK TRANSACTION; -- Ngăn chặn việc chèn bản ghi
            RETURN;
        END

        -- Xóa bản ghi đã kiểm tra khỏi bảng INSERTED
        DELETE FROM INSERTED WHERE ma_dbh IN (SELECT ma_dbh FROM INSERTED) AND ma_kh = @ma_kh;
    END
END
--17.	MODULE KIỂM TRA VÀ ĐƯA RA CẢNH BÁO ĐỐI VỚI ĐƠN HÀNG CHƯA ĐƯỢC THANH TOÁN TRONG VÒNG 1 NĂM HOẶC HƠN
CREATE OR ALTER PROCEDURE spKiemTraDonHangChuaThanhToan
AS
BEGIN
    -- Khai báo các biến cần thiết
    DECLARE @HienTai DATE = GETDATE();
    
    -- Truy vấn để lấy danh sách các đơn hàng chưa thanh toán trong vòng 1 năm
    SELECT ma_dbh, ma_kh, ngay_bh, tongtien
    FROM ban_hang
    WHERE tinhtrang_thanhtoan = '0' -- Chưa thanh toán
      AND ngay_bh <= DATEADD(YEAR, -1, @HienTai); -- Ngày bán hàng trong vòng 1 năm trở về trước

    -- Kiểm tra xem có đơn hàng nào được trả về không
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT N'Không có đơn hàng nào chưa thanh toán trong vòng 1 năm qua.';
    END
    ELSE
    BEGIN
        PRINT N'Có đơn hàng chưa thanh toán trong vòng 1 năm qua.';
    END
END
-- Xóa tất cả các bản ghi trong bảng ban_hang để bắt đầu lại
DELETE FROM ban_hang;

-- Thực thi thủ tục
INSERT INTO ban_hang (ma_dbh, ma_kh, ngay_bh, tongtien, tinhtrang_thanhtoan)
VALUES 
    ('dbh0001', 'KH0001', DATEADD(MONTH, -8, GETDATE()), 500000, '0'), -- Đơn hàng chưa thanh toán, cách đây 8 tháng
    ('dbh0002', 'KH0002', DATEADD(MONTH, -13, GETDATE()), 300000, '0'), -- Đơn hàng chưa thanh toán, cách đây 13 tháng
    ('dbh0003', 'KH0003', DATEADD(MONTH, -2, GETDATE()), 700000, '1'),  -- Đơn hàng đã thanh toán, cách đây 2 tháng
    ('dbh0004', 'KH0004', DATEADD(MONTH, -14, GETDATE()), 150000, '0'); -- Đơn hàng chưa thanh toán, cách đây 14 tháng

-- Thực thi thủ tục kiểm tra đơn hàng chưa thanh toán
EXEC spKiemTraDonHangChuaThanhToan;

-- Kiểm tra lại dữ liệu trong bảng ban_hang
SELECT * FROM ban_hang;
--18.	MODULE TỰ ĐỘNG XÓA CHI TIẾT BÁN HÀNG KHI HÀNG HÓA BỊ XÓA
CREATE OR ALTER TRIGGER trgDeleteChiTietBanHang
ON hang_hoa
AFTER DELETE
AS
BEGIN
    DECLARE @ma_hh VARCHAR(10);
    
    -- Lấy mã hàng hóa từ bản ghi bị xóa
    SELECT @ma_hh = ma_hh FROM DELETED;

    -- Xóa tất cả các chi tiết bán hàng liên quan đến hàng hóa bị xóa
    DELETE FROM chitiet_banhang
    WHERE ma_hh = @ma_hh;

    -- Kiểm tra xem việc xóa chi tiết đã thành công không
    IF @@ROWCOUNT > 0
    BEGIN
        PRINT N'Đã xóa ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + N' chi tiết bán hàng liên quan đến hàng hóa ' + @ma_hh;
    END
    ELSE
    BEGIN
        PRINT N'Không tìm thấy chi tiết bán hàng nào để xóa cho hàng hóa ' + @ma_hh;
    END
END;
--19.	MODULE GỬI THÔNG BÁO KHI KHÁCH HÀNG MỚI LẦN ĐẦU THỰC HIỆN GIAO DỊCH
CREATE OR ALTER TRIGGER trg_NotifyNewCustomer
ON ban_hang
AFTER INSERT
AS
BEGIN
    DECLARE @ma_kh VARCHAR(10);
    DECLARE @so_don_hang INT;

    -- Lấy mã khách hàng từ bảng INSERTED
    SELECT @ma_kh = ma_kh FROM INSERTED;

    -- Đếm số lượng đơn hàng của khách hàng
    SELECT @so_don_hang = COUNT(*) FROM ban_hang WHERE ma_kh = @ma_kh;

    -- Gửi thông báo nếu đây là đơn hàng đầu tiên
    IF @so_don_hang = 1
    BEGIN
        PRINT N'Chúc mừng! Khách hàng mới với mã ' + @ma_kh + N' vừa thực hiện giao dịch đầu tiên!';
    END
END
--20.	MODULE GỬI THÔNG BÁO CHO BIẾT KHÁCH HÀNG CHƯA THỰC HIỆN GIAO DỊCH NÀO TRONG VÒNG 1 NĂM
CREATE OR ALTER PROCEDURE spThongBaoKhachHangKhongGiaoDich
AS
BEGIN
    -- Khai báo các biến cần thiết
    DECLARE @HienTai DATE = GETDATE();

    -- Truy vấn để lấy danh sách khách hàng chưa thực hiện giao dịch nào trong vòng 1 năm
    SELECT DISTINCT kh.ma_kh, kh.ten_kh
    FROM khach_hang kh
    LEFT JOIN ban_hang bh ON kh.ma_kh = bh.ma_kh AND bh.ngay_bh > DATEADD(YEAR, -1, @HienTai)
    WHERE bh.ma_dbh IS NULL; -- Khách hàng không có giao dịch nào

    -- Kiểm tra xem có khách hàng nào được trả về không
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT N'Không có khách hàng nào chưa thực hiện giao dịch trong vòng 1 năm qua.';
    END
    ELSE
    BEGIN
        PRINT N'Có khách hàng chưa thực hiện giao dịch trong vòng 1 năm qua.';
    END
END;

-- Xóa tất cả các bản ghi trong bảng khach_hang để bắt đầu lại
DELETE FROM khach_hang;

-- Thêm một số khách hàng vào bảng khach_hang
INSERT INTO khach_hang (ma_kh, ten_kh, diachi, sdt)
VALUES 
    ('KH0001', N'Nguyễn Văn A', N'123 Đường A, Đà Nẵng', '0912345678'),
    ('KH0002', N'Nguyễn Văn B', N'456 Đường B, Đà Nẵng', '0912345679'),
    ('KH0003', N'Nguyễn Văn C', N'789 Đường C, Đà Nẵng', '0912345680');

-- Xóa tất cả các bản ghi trong bảng ban_hang để bắt đầu lại
DELETE FROM ban_hang;

-- Thêm một số đơn hàng vào bảng ban_hang
INSERT INTO ban_hang (ma_dbh, ma_kh, ngay_bh, tongtien, tinhtrang_thanhtoan)
VALUES 
    ('dbh0001', 'KH0001', DATEADD(MONTH, -8, GETDATE()), 500000, '1'), -- Đơn hàng đã thanh toán, cách đây 8 tháng
    ('dbh0002', 'KH0002', DATEADD(MONTH, -14, GETDATE()), 300000, '0'); -- Đơn hàng chưa thanh toán, cách đây 14 tháng

-- Thực thi thủ tục kiểm tra khách hàng chưa thực hiện giao dịch
EXEC spThongBaoKhachHangKhongGiaoDich;

-- Kiểm tra lại dữ liệu trong bảng khach_hang
SELECT * FROM khach_hang;
