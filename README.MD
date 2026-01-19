# راهنمای نصب و استفاده از اسکریپت تنظیم DNS در Cloudflare

این اسکریپت به صورت خودکار رکوردهای DNS مورد نیاز برای راه‌اندازی dnstt را در Cloudflare ایجاد می‌کند.

## این اسکریپت چه کاری انجام می‌دهد؟

1. از شما اطلاعات ورود به Cloudflare (ایمیل و API Key) را می‌پرسد
2. لیست تمام دامنه‌های شما را نمایش می‌دهد و شما یکی را انتخاب می‌کنید
3. از شما آدرس IP سرور را می‌پرسد
4. به صورت خودکار یک رکورد **A** با یک حرف تصادفی ایجاد می‌کند که به IP سرور شما اشاره می‌کند
5. یک رکورد **NS** با یک حرف تصادفی دیگر ایجاد می‌کند که به رکورد A اشاره می‌کند

## پیش‌نیازها

### برای همه سیستم‌عامل‌ها:
- دسترسی به اینترنت
- حساب Cloudflare با API Key
- دسترسی به خط فرمان (Terminal/Command Prompt)

### نرم‌افزارهای مورد نیاز:
- `bash` (در لینوکس و مک به صورت پیش‌فرض نصب است)
- `curl` (معمولاً به صورت پیش‌فرض نصب است)
- `jq` (اختیاری اما توصیه می‌شود - برای نمایش بهتر خروجی)

## نصب و اجرا

### روش 1: دانلود مستقیم و اجرا (توصیه می‌شود)

#### لینوکس و macOS:

```bash
# دانلود و اجرای مستقیم اسکریپت
curl -fsSL https://raw.githubusercontent.com/therealaleph/dnsstcloudflare/refs/heads/main/run.sh | bash
```

یا اگر می‌خواهید ابتدا دانلود کنید و بعد اجرا کنید:

```bash
# دانلود اسکریپت
curl -fsSL https://raw.githubusercontent.com/therealaleph/dnsstcloudflare/refs/heads/main/run.sh -o setup_dns.sh

# دادن مجوز اجرا
chmod +x setup_dns.sh

# اجرای اسکریپت
./setup_dns.sh
```

#### ویندوز (Git Bash):

```bash
# دانلود و اجرای مستقیم
curl -fsSL https://raw.githubusercontent.com/therealaleph/dnsstcloudflare/refs/heads/main/run.sh | bash
```

یا:

```bash
# دانلود اسکریپت
curl -fsSL https://raw.githubusercontent.com/therealaleph/dnsstcloudflare/refs/heads/main/run.sh -o setup_dns.sh

# اجرای اسکریپت
bash setup_dns.sh
```

#### ویندوز (PowerShell):

```powershell
# دانلود اسکریپت
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/therealaleph/dnsstcloudflare/refs/heads/main/run.sh" -OutFile "setup_dns.sh"

# اجرا با Git Bash (اگر نصب دارید)
bash setup_dns.sh
```

### روش 2: کلون کردن از گیت‌هاب

```bash
# کلون کردن مخزن
git clone https://github.com/therealaleph/dnsstcloudflare.git

# رفتن به پوشه
cd dnsstcloudflare

# اجرای اسکریپت
bash run.sh
```

## نصب نرم‌افزارهای مورد نیاز

### macOS:

```bash
# نصب Homebrew (اگر نصب نیست)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# نصب jq (اختیاری اما توصیه می‌شود)
brew install jq
```

### لینوکس (Debian/Ubuntu):

```bash
# به‌روزرسانی لیست پکیج‌ها
sudo apt-get update

# نصب jq (اختیاری اما توصیه می‌شود)
sudo apt-get install jq
```

### لینوکس (RHEL/CentOS/Fedora):

```bash
# نصب jq (اختیاری اما توصیه می‌شود)
sudo yum install jq
# یا برای Fedora جدیدتر:
sudo dnf install jq
```

### ویندوز:

1. **نصب Git Bash**: از [این لینک](https://git-scm.com/downloads) دانلود و نصب کنید (شامل bash و curl است)
2. **نصب jq (اختیاری)**: از [این لینک](https://stedolan.github.io/jq/download/) دانلود کنید

## نحوه استفاده

### مرحله 1: اجرای اسکریپت

اسکریپت را با یکی از روش‌های بالا اجرا کنید.

### مرحله 2: وارد کردن اطلاعات Cloudflare

اسکریپت از شما می‌پرسد:

```
Cloudflare API Credentials:
Enter your Cloudflare Email: [ایمیل خود را وارد کنید]
Enter your Cloudflare API Key: [API Key خود را وارد کنید - نمایش داده نمی‌شود]
```

### مرحله 3: انتخاب دامنه

اسکریپت لیست تمام دامنه‌های شما را نمایش می‌دهد:

```
Available domains:

  1. example.com
  2. another-domain.com
  3. mydomain.ir

Select domain by number (1-3): [شماره دامنه مورد نظر را وارد کنید]
```

فقط شماره دامنه مورد نظر را وارد کنید (مثلاً `3`).

### مرحله 4: وارد کردن IP سرور

```
Enter server IP address: [آدرس IP سرور خود را وارد کنید]
```

آدرس IP سرور خود را وارد کنید (مثلاً `123.123.123.123`).

### مرحله 5: صبر کنید

اسکریپت به صورت خودکار:
- رکورد A را ایجاد می‌کند
- رکورد NS را ایجاد می‌کند
- نتیجه را نمایش می‌دهد

## مثال خروجی

```
========================================
Cloudflare DNS Setup
========================================

Cloudflare API Credentials:
Enter your Cloudflare Email: your@email.com
Enter your Cloudflare API Key: [hidden]
Enter your domain (e.g., example.com): example.com
Enter server IP address: 123.123.123.123

Setting up DNS records...

Getting Zone ID for example.com...
✓ Found zone ID: abc123def456

Creating A record:
  Name: z.example.com
  Type: A
  Content: 123.123.123.123
  Proxied: false

✓ A record created: z.example.com -> 123.123.123.123

Creating NS record:
  Name: s.example.com
  Type: NS
  Content: z.example.com
  Proxied: false

✓ NS record created: s.example.com -> z.example.com

========================================
Setup Complete!
========================================

DNS Records Created:
  A Record:  z.example.com -> 123.123.123.123 (unproxied)
  NS Record: s.example.com -> z.example.com (unproxied)

Use this DNS name for dnstt: s.example.com

All done!
```

## نحوه دریافت API Key از Cloudflare

1. به [پنل Cloudflare](https://dash.cloudflare.com/) بروید و وارد حساب خود شوید
2. روی آیکون پروفایل (سمت راست بالا) کلیک کنید
3. روی **"My Profile"** کلیک کنید
4. به تب **"API Tokens"** بروید
5. در بخش **"API Keys"** روی **"View"** کنار **"Global API Key"** کلیک کنید
6. رمز عبور خود را وارد کنید
7. **Email** و **Global API Key** خود را کپی کنید

⚠️ **هشدار امنیتی**: API Key خود را با کسی به اشتراک نگذارید و آن را در فایل‌های عمومی قرار ندهید!

## توضیحات مهم

### رکورد A چیست؟
رکورد A یک آدرس IP را به یک نام دامنه متصل می‌کند. در این اسکریپت، یک حرف تصادفی (مثلاً `z`) به دامنه شما اضافه می‌شود و به IP سرور شما اشاره می‌کند.

**مثال**: `z.example.com` → `123.123.123.123`

### رکورد NS چیست؟
رکورد NS مشخص می‌کند که کدام سرور DNS مسئول یک زیردامنه است. در این اسکریپت، یک حرف تصادفی دیگر (مثلاً `s`) ایجاد می‌شود که به رکورد A اشاره می‌کند.

**مثال**: `s.example.com` → `z.example.com`

### چرا unproxied؟
رکوردها به صورت **unproxied** (ابری نشده) ایجاد می‌شوند. این یعنی:
- در پنل Cloudflare، ابر خاکستری است (نه نارنجی)
- ترافیک مستقیماً به سرور شما می‌رود (از طریق Cloudflare پروکسی نمی‌شود)
- برای dnstt این حالت ضروری است

### استفاده از نام DNS برای dnstt
از نام رکورد **NS** (که یک حرف است) برای تنظیمات dnstt استفاده کنید.

**مثال**: اگر رکورد NS شما `s.example.com` است، در تنظیمات dnstt از `s.example.com` استفاده کنید.

## عیب‌یابی

### خطا: "curl is not installed"
**راه حل**: curl را نصب کنید:
- macOS: `brew install curl`
- لینوکس: `sudo apt-get install curl` یا `sudo yum install curl`
- ویندوز: با نصب Git Bash، curl به صورت خودکار نصب می‌شود

### خطا: "Error getting zones"
**راه حل**: 
- مطمئن شوید Email و API Key را درست وارد کرده‌اید
- بررسی کنید که API Key معتبر است
- اتصال اینترنت خود را بررسی کنید

### خطا: "No zones found"
**راه حل**: 
- مطمئن شوید که حداقل یک دامنه در حساب Cloudflare خود دارید
- بررسی کنید که دامنه‌ها فعال هستند

### خطا: "DNS name is invalid"
**راه حل**: 
- این خطا معمولاً به دلیل مشکل در تولید حرف تصادفی است
- اسکریپت را دوباره اجرا کنید

### خطا: "Permission denied"
**راه حل**: 
- در لینوکس/مک: `chmod +x setup_dns.sh` را اجرا کنید
- در ویندوز: از Git Bash استفاده کنید

## سوالات متداول

### آیا این اسکریپت امن است؟
بله، این اسکریپت فقط از API رسمی Cloudflare استفاده می‌کند و هیچ اطلاعاتی را ذخیره نمی‌کند. API Key شما فقط برای ارتباط با Cloudflare استفاده می‌شود.

### آیا می‌توانم چند بار از این اسکریپت استفاده کنم؟
بله، می‌توانید برای هر سرور یا دامنه جدید از این اسکریپت استفاده کنید.

### آیا می‌توانم رکوردهای ایجاد شده را حذف کنم؟
بله، می‌توانید از پنل Cloudflare یا API خود رکوردها را حذف کنید.

### آیا می‌توانم حروف را خودم انتخاب کنم؟
خیر، در نسخه فعلی حروف به صورت تصادفی انتخاب می‌شوند. اما می‌توانید بعداً از پنل Cloudflare آنها را تغییر دهید.

## پشتیبانی

اگر مشکلی داشتید یا سوالی دارید:
1. بررسی کنید که تمام پیش‌نیازها نصب هستند
2. مطمئن شوید که API Key معتبر است
3. لاگ خطاها را بررسی کنید

## لایسنس

این اسکریپت به صورت رایگان و متن باز ارائه شده است.

---

**نکته مهم**: همیشه API Key خود را محرمانه نگه دارید و آن را در فایل‌های عمومی یا مخازن گیت قرار ندهید!
