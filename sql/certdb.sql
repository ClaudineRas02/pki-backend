--
-- PostgreSQL database dump
--

\restrict dcKfmQPiLVxbfbbKgf70XKcgunMCPJsa7eeB6WaXgtPqwzSfGnc2hXRXmKS2hnb

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: algorithm_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.algorithm_type AS ENUM (
    'RSA_2048',
    'RSA_4096',
    'ECDSA'
);


--
-- Name: ca_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.ca_type AS ENUM (
    'ROOT',
    'INTERMEDIATE'
);


--
-- Name: cert_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cert_type AS ENUM (
    'SERVER',
    'CLIENT',
    'CA'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: certificate_authorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificate_authorities (
    ca_id integer NOT NULL,
    name text NOT NULL,
    ca_type public.ca_type,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    parent_ca_id integer,
    private_key text,
    certificate text,
    expires_at timestamp without time zone,
    status text DEFAULT 'VALID'::text,
    subject_dn text,
    issuer_dn text,
    serial_number text,
    fingerprint_sha256 text,
    key_path text,
    cert_path text,
    serial_path text,
    source_format text,
    CONSTRAINT certificate_authorities_status_check CHECK ((status = ANY (ARRAY['VALID'::text, 'EXPIRED'::text, 'REVOKED'::text])))
);


--
-- Name: certificate_authorities_ca_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificate_authorities_ca_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificate_authorities_ca_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificate_authorities_ca_id_seq OWNED BY public.certificate_authorities.ca_id;


--
-- Name: certificate_sans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificate_sans (
    san_id integer NOT NULL,
    certificate_id integer,
    domain text NOT NULL
);


--
-- Name: certificate_sans_san_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificate_sans_san_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificate_sans_san_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificate_sans_san_id_seq OWNED BY public.certificate_sans.san_id;


--
-- Name: certificate_signing_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificate_signing_requests (
    csr_id integer NOT NULL,
    common_name text NOT NULL,
    algorithm text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status text DEFAULT 'PENDING'::text,
    subject_dn text,
    csr text,
    private_key text,
    csr_path text,
    key_path text,
    source_format text,
    signed_certificate_id integer,
    ca_id integer,
    CONSTRAINT certificate_signing_requests_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'SIGNED'::text, 'IMPORTED'::text])))
);


--
-- Name: certificate_signing_requests_csr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificate_signing_requests_csr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificate_signing_requests_csr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificate_signing_requests_csr_id_seq OWNED BY public.certificate_signing_requests.csr_id;


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates (
    cert_id integer NOT NULL,
    common_name text NOT NULL,
    cert_type public.cert_type,
    algorithm public.algorithm_type,
    issued_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone,
    status text DEFAULT 'VALID'::text,
    ca_id integer,
    subject_dn text,
    issuer_dn text,
    serial_number text,
    fingerprint_sha256 text,
    key_path text,
    cert_path text,
    source_format text,
    csr_id integer,
    CONSTRAINT certificates_status_check CHECK ((status = ANY (ARRAY['VALID'::text, 'EXPIRED'::text, 'REVOKED'::text])))
);


--
-- Name: certificates_cert_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificates_cert_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificates_cert_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificates_cert_id_seq OWNED BY public.certificates.cert_id;


--
-- Name: csr_sans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.csr_sans (
    csr_san_id integer NOT NULL,
    csr_id integer,
    domain text NOT NULL
);


--
-- Name: csr_sans_csr_san_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.csr_sans_csr_san_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: csr_sans_csr_san_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.csr_sans_csr_san_id_seq OWNED BY public.csr_sans.csr_san_id;


--
-- Name: certificate_authorities ca_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_authorities ALTER COLUMN ca_id SET DEFAULT nextval('public.certificate_authorities_ca_id_seq'::regclass);


--
-- Name: certificate_sans san_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_sans ALTER COLUMN san_id SET DEFAULT nextval('public.certificate_sans_san_id_seq'::regclass);


--
-- Name: certificate_signing_requests csr_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_signing_requests ALTER COLUMN csr_id SET DEFAULT nextval('public.certificate_signing_requests_csr_id_seq'::regclass);


--
-- Name: certificates cert_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates ALTER COLUMN cert_id SET DEFAULT nextval('public.certificates_cert_id_seq'::regclass);


--
-- Name: csr_sans csr_san_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csr_sans ALTER COLUMN csr_san_id SET DEFAULT nextval('public.csr_sans_csr_san_id_seq'::regclass);


--
-- Data for Name: certificate_authorities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.certificate_authorities (ca_id, name, ca_type, created_at, parent_ca_id, private_key, certificate, expires_at, status, subject_dn, issuer_dn, serial_number, fingerprint_sha256, key_path, cert_path, serial_path, source_format) FROM stdin;
5	Test Root 1777600235628	ROOT	2026-05-01 04:50:35.820466	\N	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDlzqW87UXFfgDf\nPfC4vpDZPDLiQN3P1l4BOFOpu3fh0HQevmuLWdxf1jEMaxoOjNcKPEFMGw0Y8Ce7\nrLt3TeQO1iayJrRNy6T3dLls0ifI/BDj4lw0YKBtS13I21AJ4sTgZsywMy5NoE9k\n2guEQmykHrDyYxttPMqRkpruCHetCJ8yD2JEXXMyiE5jqCkMj4HsBnBby/vMaB+x\n6/EourVnTuqCqSkK+PwDgVw1TnB2rLlwlGFaipjsunSGgm8NdTSuDlYaZ7BD2uUp\nHQp7N04emEYM+aY2hE5IRIwAUEdOoZ8tKD8rN4AGDo8C8o394CjzY5B1Q85oQEG+\npLv44x37AgMBAAECggEADttAW7ZhjFYl0eJvOk8Xjibi8ApbGW41i/g+o5QH0msB\nFsiFeCMwqM483YPb0cgvhSBGfst0GhvS3CjBwpsgFm8OkVw7/v64Hq2tG+itXPdV\nIDModgcvixR6og5YXks97xC2RHqkKhO/2wU9n8J4XSPR/9mB+TROfc3vtibvlbMz\nOcN+LPYFbnrTklHOqXancw4/u4dSsnZtmrci+M4BbV7NlUrTyUc30U5AHIRsXCuc\nUvCjv89Yt00ILeWpyPbgRbFNyAM8rD3fOQ99v2HzATYAeU4jkmv+tYqwJaCgWWQ5\n3M3GWNQvvVrFsgog/AOHmwKcFxM9UpPsPdlTxfWeAQKBgQD2973ufXxeiC5FvXKz\nVn8HxaJvjrLrx7qSXWs0vUgVXIQY9EkkLN+96unUpD2OXrltItMucDC1TY/4TBTY\naH8pkzKzJmijiCvyffdzLbK86edjsbf4AQpDzqphhhx8/5c4g+7TYl2VP6LAk8ga\n762xg8ofE72GWaHPuFC4hfCjxwKBgQDuNj0OoCX2nfYjsqUop9JbA2+hFJlc9jSC\nPWaUZisL03qwPskKnQwHP6tb/dfjN8JAykOx6+d9ISOOUrpFtlKugKj2HLt6yGM7\n6tZ8G6algqX0YVWXW/rweQjOnYoNLw3gzFcB0Idq4BT/7pir6rvqYEmLrAGRkQ6p\naP0ZiM8MLQKBgQC9/W6m9vBjhN4cFpcTsfn9j6PbsGqiij9Uc/uSUf8PN+IDlIJk\nCwWBBCQoysT0Lpj1hXHy6qn+ABI+kMEEjrcs06mQOn8LNymf3hosCD7VqBezETgW\n2S39ZhKa/eISo0nBV3W2NpkJxS++eLHbTwFPa7RlXflSTsf1lbS7j4bFZwKBgQDm\njL4ZWqyDfKyOLkelCpAQIEo5B5vLGksFxnFyrVN6Narny0x+pjLPDTNHbG427m9m\nj5xnJh+8vocQJ0c7U1PAqqtcz8Av/KP2iLogEg7+32zJEi9pt88uUKZSeqzzR5hR\n+tM24WE+8jPA5GcE9MH8/EYSFV7LSS58ji1wOjXR3QKBgEshkv3sAcyQNey7cOb0\nXg9jFrbl9RAl4A399LNPuFktDe8SKM+7fONzCisiC5qaWcFDovo0SQOCqMHpA8V/\nw4iEP2ydn1PHf5FSlG5BUEK5xJGtiFZXeiQuwz1HuLb7hbV2Cc4YHHokgFEkJOXA\nuUZA6iUUFIlURW2BfiN4N4al\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIEPDCCAySgAwIBAgIUS57ZIrSO/wbgM5IOuM4pGd8LF4IwDQYJKoZIhvcNAQEL\nBQAwgaMxCzAJBgNVBAYTAk1HMRMwEQYDVQQIDApBbmFsYW1hbmdhMRUwEwYDVQQH\nDAxBbnRhbmFuYXJpdm8xEzARBgNVBAoMClRlY2hNb2JpbGUxDDAKBgNVBAsMA1BL\nSTEgMB4GA1UEAwwXVGVzdCBSb290IDE3Nzc2MDAyMzU2MjgxIzAhBgkqhkiG9w0B\nCQEWFHBraUB0ZWNobW9iaWxlLmxvY2FsMB4XDTI2MDUwMTAxNTAzNVoXDTI3MDUw\nMTAxNTAzNVowgaMxCzAJBgNVBAYTAk1HMRMwEQYDVQQIDApBbmFsYW1hbmdhMRUw\nEwYDVQQHDAxBbnRhbmFuYXJpdm8xEzARBgNVBAoMClRlY2hNb2JpbGUxDDAKBgNV\nBAsMA1BLSTEgMB4GA1UEAwwXVGVzdCBSb290IDE3Nzc2MDAyMzU2MjgxIzAhBgkq\nhkiG9w0BCQEWFHBraUB0ZWNobW9iaWxlLmxvY2FsMIIBIjANBgkqhkiG9w0BAQEF\nAAOCAQ8AMIIBCgKCAQEA5c6lvO1FxX4A3z3wuL6Q2Twy4kDdz9ZeAThTqbt34dB0\nHr5ri1ncX9YxDGsaDozXCjxBTBsNGPAnu6y7d03kDtYmsia0Tcuk93S5bNInyPwQ\n4+JcNGCgbUtdyNtQCeLE4GbMsDMuTaBPZNoLhEJspB6w8mMbbTzKkZKa7gh3rQif\nMg9iRF1zMohOY6gpDI+B7AZwW8v7zGgfsevxKLq1Z07qgqkpCvj8A4FcNU5wdqy5\ncJRhWoqY7Lp0hoJvDXU0rg5WGmewQ9rlKR0KezdOHphGDPmmNoROSESMAFBHTqGf\nLSg/KzeABg6PAvKN/eAo82OQdUPOaEBBvqS7+OMd+wIDAQABo2YwZDAdBgNVHQ4E\nFgQUuxV8z0nZceqwsrLZ8ub74vMOQc8wDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8B\nAf8EBAMCAYYwIgYDVR0RBBswGYIXVGVzdCBSb290IDE3Nzc2MDAyMzU2MjgwDQYJ\nKoZIhvcNAQELBQADggEBAK5pBl676rK25vrODfTWGZ4oVEZs24/4Q0TExRTXhKCZ\nv8grJHUq1f6WFDRRmcjK/BatXSSr2Ish6sw9gwxZ3eFPcul+gPzdpSL/hY7ekfUA\nmSuca4dwa0kJQl1jVsSPD3uWafqken/1tb067BOdEa7Gun313iU+nMTA5N/oOFmt\nUiXiOF9RN0h/d6FLRJFhsk541WnUr5v2PXw+xfWWPf95djeYc0jQvMcrDwZ+bvGM\naqgGV/uxIfVVTa+RVdUaGoW00SdxZV0BaiISy+ftOzFw1E7x9qFCx2JwiC7rAkM5\nVJrnCwl/0maZUawlCm1ROn28B+DRKQhUt8llUyMwNDo=\n-----END CERTIFICATE-----\n	2027-05-01 01:50:35	VALID	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=PKI, CN=Test Root 1777600235628, emailAddress=pki@techmobile.local	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=PKI, CN=Test Root 1777600235628, emailAddress=pki@techmobile.local	4B9ED922B48EFF06E033920EB8CE2919DF0B1782	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777600235628-z1tpfo/test-root-1777600235628.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777600235628-z1tpfo/test-root-1777600235628.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777600235628-z1tpfo/test-root-1777600235628.srl	pem
6	Test Root 1777600262376	ROOT	2026-05-01 04:51:02.518579	\N	-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCS5BEMu0kq+/FL\neWLy4bnkKugXlE617BtcqApQHVcIwK2hvdSP8wWKKPu6c3kCpo2KsI8kK9MZCI1A\neTFK600l3BKBYwHBDmkzXj6Dvkegp9iJ2Ac6vS49dAOb/wdczDxbFELUXkLmtb9i\nyxvgmIHHzykeQKCrsRtXA1Cv1lhkkMbmx23Et3WrueblyE/Dp8huJCi5QkjslsID\nxmBjvCwWbijGWjxK3yvG25P1ouqBWMyeXo+GAJASSNasf+TdKulKs7QqbqVMkRx5\nZxxjv4jHexQ0kcxDRoJXr+PcLbuMw3sina3P+qfVl/lLhn2WA0VaiMT9fEdjZrYy\nFwFvip3rAgMBAAECggEABmdM2vo7KVWMYlbrWl0+xlScg5Kij8m4M6TbtjxhM+96\nYketQY09m5VHzAwGpXfvSbGCu/fxHvFBfyMJZBO37EOYxu0zAWCIc4XTQdkEtFs8\n1F2Hiyb+Ig2xrpZCkugQZYQPmcR2NCqOKldiYrsjRTuhtkDpADMbVwK8/L1iYxff\ntzmcusOhUPqamRBKAB8BuyKXRbnsv9gvnLfa3F3LBwI1M0M5D+XTZ013EQynzc3y\nT0kowM0LTl4ilN0+iIMEQp9L4f7lXqVZqAgWak2b6qiutnZkeSDste7WY24jun2w\nLaLwGTo4e2D54y52P7HvztsuNa3G6OyRv3MhLubgCQKBgQDK1DrmUAiEYYR8cHei\nKkUEL+P6S7biJHqEA5TqYfkAfZqWAgKaN9b65eyOw7zfy2heGusaD7VrkV4cnfWI\nkHjif3OJmi9y9WnwTmrRnNK5E53n3kVaN9+PETTOlDTDQOC9WqYkr8oMq7mXNypS\nn55vUJIpKv3W/3C8DQHZtJMebQKBgQC5ZdoKg2+Vv8bhwGnw2vnDbIwhI1WYn1iY\nPbWqUOoF+xn71LO3qICXpLsyIVi/q6gzQ5xQo2H7bYXWMVKXR/yZD5GpPO88mK3S\nK7mtCcSPKdHCl0Cfm0Vz3tlReKuJlBHQNea2uDhWj/oMC4woQqF0B7lnJbzXMY9o\nzf+A+TyWtwKBgArSokXx1VKDBZfCRI/xo3ciuw57BcoxWhw7OLH9AlVlXl9MwijK\ne/0tUZ8YkLZ8WxhSZWMhnXOc8SGjyBs+YkTruhWIlamTsNByzr5amN/pTQ63TIoQ\n2yv+Jgwz2lDk4FkaQi1I+AYPD7si5W49OC4GZZYuxha30KMoKoYcXZFNAoGATPow\nJQtbqladMiCdHCcfavfH2v57zMnklBmTMyszb9ZJfJldIVVyRwRbwT29Rp/0T4yz\n+3tK9IUN+9gwzaVTCQ5A0X7+ai+OhGQpTOJwXWzkriH08BAdLzYJD13GA3KaTtQC\nfj1RDwfqr1OgFxtLRAzs+xndJZBrVf2qJ5fUg1MCgYBojAm6i50EuWGiUk/1VgD1\n6hQyStTsNNJFWX5H7pUymTnd8iA8mbZWQE7AbfDThIwGFjx5W7ZQbURI0yg7JSLO\ntl9piN3ma+DvzbaT/yXUHoNHNxvAOphCFxYkFvgDS4xGFRCHAPYgPVtivK+HNoFH\nxsKi1NxakDsl0Awh7HzdrA==\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIEPDCCAySgAwIBAgIUc1jNlzdtQ8weWL45jh8vq9YEYxYwDQYJKoZIhvcNAQEL\nBQAwgaMxCzAJBgNVBAYTAk1HMRMwEQYDVQQIDApBbmFsYW1hbmdhMRUwEwYDVQQH\nDAxBbnRhbmFuYXJpdm8xEzARBgNVBAoMClRlY2hNb2JpbGUxDDAKBgNVBAsMA1BL\nSTEgMB4GA1UEAwwXVGVzdCBSb290IDE3Nzc2MDAyNjIzNzYxIzAhBgkqhkiG9w0B\nCQEWFHBraUB0ZWNobW9iaWxlLmxvY2FsMB4XDTI2MDUwMTAxNTEwMloXDTI3MDUw\nMTAxNTEwMlowgaMxCzAJBgNVBAYTAk1HMRMwEQYDVQQIDApBbmFsYW1hbmdhMRUw\nEwYDVQQHDAxBbnRhbmFuYXJpdm8xEzARBgNVBAoMClRlY2hNb2JpbGUxDDAKBgNV\nBAsMA1BLSTEgMB4GA1UEAwwXVGVzdCBSb290IDE3Nzc2MDAyNjIzNzYxIzAhBgkq\nhkiG9w0BCQEWFHBraUB0ZWNobW9iaWxlLmxvY2FsMIIBIjANBgkqhkiG9w0BAQEF\nAAOCAQ8AMIIBCgKCAQEAkuQRDLtJKvvxS3li8uG55CroF5ROtewbXKgKUB1XCMCt\nob3Uj/MFiij7unN5AqaNirCPJCvTGQiNQHkxSutNJdwSgWMBwQ5pM14+g75HoKfY\nidgHOr0uPXQDm/8HXMw8WxRC1F5C5rW/Yssb4JiBx88pHkCgq7EbVwNQr9ZYZJDG\n5sdtxLd1q7nm5chPw6fIbiQouUJI7JbCA8ZgY7wsFm4oxlo8St8rxtuT9aLqgVjM\nnl6PhgCQEkjWrH/k3SrpSrO0Km6lTJEceWccY7+Ix3sUNJHMQ0aCV6/j3C27jMN7\nIp2tz/qn1Zf5S4Z9lgNFWojE/XxHY2a2MhcBb4qd6wIDAQABo2YwZDAdBgNVHQ4E\nFgQU2/9LYEY4b9idENm1zPjdyK/yAmcwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8B\nAf8EBAMCAYYwIgYDVR0RBBswGYIXVGVzdCBSb290IDE3Nzc2MDAyNjIzNzYwDQYJ\nKoZIhvcNAQELBQADggEBAFybz1csWl+X9W3+4KkEUt6N1ImawDIiEwf1+EvR7epw\nTfzlL3PRjpiclfaEONDghPK7bwYxF/BcbTS1FJt1y7qy3R7mIfxtJzxqjw9oLTb/\nDTGBN6cHCAvgu5vWTlD3qaazBmp9jvAixukO/PG6wst1ZkHKeIZVUwQYFzI9KfMT\nc/6NJBwUovo/ACWA0JMzsWooOQdOfnXRbS701paskz3TPG+4cnuI3dWtvpojT2IR\npAPJhBcypoy19cja+nt3q2clSy3Flm+pql21647ElPU5yj1suZ1WOwSXsAaVToD6\nBzcFT6TYgKKz5sP7aTUINGk9bt6274imP4Ox2+QskY4=\n-----END CERTIFICATE-----\n	2027-05-01 01:51:02	VALID	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=PKI, CN=Test Root 1777600262376, emailAddress=pki@techmobile.local	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=PKI, CN=Test Root 1777600262376, emailAddress=pki@techmobile.local	7358CD97376D43CC1E58BE398E1F2FABD6046316	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777600262377-ug6hxp/test-root-1777600262376.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777600262377-ug6hxp/test-root-1777600262376.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777600262377-ug6hxp/test-root-1777600262376.srl	pem
7	test	ROOT	2026-05-01 08:34:42.021893	\N	-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCXgmRJhU/mkDZf\nG4MWZedajWITC1nUhlhYGQVkJpjSty19jGBi3VyImsEwq6M35x+J5X/FUW9E2dvY\nBHpaWyEOqRFZ2Sht7ynxnpc89GccnUG96FGm0g/Krbd1vOJubGWUhUvgZ3CawBMi\nt01LXg48B0GkItn8k1fyuHec+Q7sA5WzDDTv0ij+SGKkZ4pVzvx73P4gDavHZY9J\naqZ2QAGb6zbnj+EubX/Z74rGk1FZVAam1hi5e7rJdOSyssExdXKJRMCzzGPxVu6I\n5LLGhNv+pWFjSpMLJe6Pal2UB2Q6+cK9XCSv7BhZflGIkP9LYAmALQuc5wNH9buL\njN8FFQWNAgMBAAECggEAAxjY60vSAKONXk+rU/zh8s7rD0/vFny8jOh4shMRPVVz\nP5rBVE60F91vT4sNUL+PvHuNgL9pEojliTqQ3wyigLCMuJUg0hvOdAWgOnsV1IGT\nw3RenutdA/FIdnFVq5jZprnm0tUqecStX3X3Gtr3AtvJyAzSVJW/ztKzLJPxbc+e\nOcnDEcA7PZqTr6JlRzMblJOo76VAdgON6t9z1Sci/VODWcPWO6OZthO9T99MORLM\nJTTSpxbkPt601NCK4RnGCIx4g4SJCU6WJX7g2S10E0JT76yGPjlBBIo6bY8PHPRy\nSCckBgLeSZf+yxMQRF25aDpZr8tkiqEg0g86CF4mAQKBgQDLb+L0tdOGkD58td1y\neOxE3KSoiOv7rthAMUAGywkz0NPCotIp/44qrjaU7i2GlxOk1Vd5c1vDuqWDKbeG\nFMSZ4KmPTMSsQUscvIN6X2s/vvhusYYF+f+dLWQoRoBGbNUQ8+SCbd1Tsg2Zo4QZ\nlEeUdiYzjK8sFefpnwPsbIuwgQKBgQC+p84w11VkWzgWTS2fCt148LT0tj5lIw8j\nMF1Rx099w7vrRBF6Y3Rhp0Xpf51BGfV+7WZxru43kLLGNHJ3oQ6FBqeaH41gUy8F\ncPgeFcOyqVYXUfFIUmiEYVccLtwmyK+Sx3nEDWaMxE4Ogomt1YtpIwrfjU4Bvb3r\n0B3rF+WPDQKBgBsrsWM/maXCRCZB3/a3Ac9crL05tFLkEkvYiBWgLnV2MaIwPuOP\nFzzKEc4oVXpBWUVNnSZCawIkPpDbFIDa6zsmD19tQGNFQTPwVZsVfWyBJAscuKq5\nrhMfCd57NAyz4m0mNeHZrJLOGBTqCu2jqT/B2+5MnuTDdDr2mv6LrMiBAoGAB3/u\nWnl+AG6eLDJpAwKYZ7OASsgIeE4CwG2cniTq+ZWDhOOulFPpNhYwZ9j/RJpSz+Vi\nzEIHWOQ2RBm4DwCk45K5cRSgqRNcnCgvem98vUBwBIbSqPek6OAzXwZw3o2yamGy\nZoXobM0kDOoRpGbsDvyz5stWMDdYizgqlR7hhtkCgYAa+0pndgQ2jUDIL5YFAubJ\nN2ZQ1V8fksGcOxe9HphBgSD7ylGrMS4rq+EotMJAIDdI2SI8Cc4VDFbHOLKq+elH\nUJHdDUVu+h1Zpw5hesc9FwDfXGiWB0JH/2pbCcL40fiOO3xojVuWxm+5SHQKEddI\n4X08p0TjoRRem/eZLQJrRw==\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIEMjCCAxqgAwIBAgIUOKpoLAiMcJjp4oWpUSj9xKGlkKowDQYJKoZIhvcNAQEL\nBQAwgaMxCzAJBgNVBAYTAk1HMRgwFgYDVQQIDA9IYXV0ZSBtYXRzaWF0cmExFjAU\nBgNVBAcMDUZpYW5hcmFudHNvYSAxDDAKBgNVBAoMA0VuaTESMBAGA1UECwwJU2Vj\ndXJpdHkgMRYwFAYDVQQDDA1sb2NhbC5wcm9qZWN0MSgwJgYJKoZIhvcNAQkBFhlo\nYW5pdHJhY2xhdWRpbmVAZ21haWwuY29tMB4XDTI2MDUwMTA1MzQ0MVoXDTI3MDUw\nMTA1MzQ0MVowgaMxCzAJBgNVBAYTAk1HMRgwFgYDVQQIDA9IYXV0ZSBtYXRzaWF0\ncmExFjAUBgNVBAcMDUZpYW5hcmFudHNvYSAxDDAKBgNVBAoMA0VuaTESMBAGA1UE\nCwwJU2VjdXJpdHkgMRYwFAYDVQQDDA1sb2NhbC5wcm9qZWN0MSgwJgYJKoZIhvcN\nAQkBFhloYW5pdHJhY2xhdWRpbmVAZ21haWwuY29tMIIBIjANBgkqhkiG9w0BAQEF\nAAOCAQ8AMIIBCgKCAQEAl4JkSYVP5pA2XxuDFmXnWo1iEwtZ1IZYWBkFZCaY0rct\nfYxgYt1ciJrBMKujN+cfieV/xVFvRNnb2AR6WlshDqkRWdkobe8p8Z6XPPRnHJ1B\nvehRptIPyq23dbzibmxllIVL4GdwmsATIrdNS14OPAdBpCLZ/JNX8rh3nPkO7AOV\nsww079Io/khipGeKVc78e9z+IA2rx2WPSWqmdkABm+s254/hLm1/2e+KxpNRWVQG\nptYYuXu6yXTksrLBMXVyiUTAs8xj8VbuiOSyxoTb/qVhY0qTCyXuj2pdlAdkOvnC\nvVwkr+wYWX5RiJD/S2AJgC0LnOcDR/W7i4zfBRUFjQIDAQABo1wwWjAdBgNVHQ4E\nFgQUwy1FP7CN78uTDvAN+MDfORn3ibEwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8B\nAf8EBAMCAYYwGAYDVR0RBBEwD4INbG9jYWwucHJvamVjdDANBgkqhkiG9w0BAQsF\nAAOCAQEAhWf62KtpEn5KeWaet1JMF/u5iRaCxPZFKro588lrF4NGaTrX2L+F1ODk\nEEeZ0xF5DdS4JwYLRKIYy0qnR8iKT6yZYiVRz4HGFQaueST9l6VP2zzvs49cFL0m\nRpfYVNcXNliXvJsQWz/mGm9EvwSApmhBtan3hd/RQWEMe4AZpqxAFVDfF5OIJumj\nb1H/U6HN6fPvlmuSOUonXzvOTz7QBXVdC2dLmgLe/8zwy81Nsd60nvNrKrj0EIIm\nGsgTHwtHaosCWdD9bzRtxUQ1CNTmK4jKaT/HTN16Zss9JGl1KOzzZiimou4+UH7F\nlEbQiNfPWt158QR/TDirGmBJzHfrLw==\n-----END CERTIFICATE-----\n	2027-05-01 05:34:41	VALID	C=MG, ST=Haute matsiatra, L=Fianarantsoa , O=Eni, OU=Security , CN=local.project, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=Haute matsiatra, L=Fianarantsoa , O=Eni, OU=Security , CN=local.project, emailAddress=hanitraclaudine@gmail.com	38AA682C088C7098E9E285A95128FDC4A1A590AA	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777613681866-lnq1pb/test.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777613681866-lnq1pb/test.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777613681866-lnq1pb/test.srl	pem
8	test2	ROOT	2026-05-01 08:51:30.225558	\N	-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDdMhF6RhvKZBtb\nFZ3BYQSXvhG9FcUJb8/dFdC0DDCn/RSzOrSoCyYFwhPFSeFvEm9TNJMDNkHMt3vU\nAqkWAYFV0+pFK7lkNVZ/hIPjSSYRa48otvxQBvC7k7sI9pXD0ILUQvKgSnXCRd00\nszcohmR7QbIk+JZcAsfr/Wyp3RRzG13QTWFtrscOy7Ibu7EclMv+T7W1wex8hbpe\n7TlPZGftcoIynCHDpbIG/FJFWrVSh5m+6QRVqEaQ4ChZh3jFjn2QnXf7o1xMruyS\ney2Udvg571KBq27H+kZEQ7Mi9+ZX/PP3XJxkTYjj+8oAtP8jTw/ZK1u/hUxYbl6h\nq7Eyek6XAgMBAAECggEANu4fHwFYF2vCy1zT31kLfe9qkk1csBo/QYUQXhYE40Lb\nKCM1B+I04AsxQ7Y0MJQgZ0ZQF+UadA9AxgafHOLkzn6g1+qi0HrabzJmWkQpGvxe\nAdtnTyxaDgsC0JgD2yvlwXaasCmtksAszdCPqxWs0FshNUMye8kJAtbdbFWFpYu4\n6hgITm6ptgupAXhHPFv4e7oeq4A4onzP0aMmdNbTc39B0vcXIqybKgfvBAygpwIU\n6nB/4piscO6gbvNQMKmeYEflCXfCG6vvZsehIo7cLtPR4pgMKAaT5IptN9gNgoto\nrZSwvcvr1Sua3TIN0efRztfX2DS3SgpzJOIWh5j64QKBgQD6UZ7kUk/nrFRSLTDr\nxeHsEf9u5zN5zll1B2ORHTNjbs8Ts9cjJXd0wwnc1sQadz/p7m0P2288T7e0YXku\nHI9IEDS133IfTTxfGVDqNquTf2RvojxqcVF+Q+5MpgYA/hPNrYKfCcBV2411XUE8\nAx//O14t2JDfpLo53wK2NxE4BwKBgQDiNz0GQxqqpdCXrPXxCpRoqmmgZKaDH1c5\nRS6EmZwFky+X7HAdp/v4S++sgHJyd/OU4IWbnoCX+Be+C+keymDTmhNjcYNekumH\n0KsrP/ieyq5ccNLndS3S6nLZm+2UlffCR5CfHBgtNiZyEmEDIVp/vGawmVoDveqU\nvAjEd9Lw8QKBgDbJdoVynpqOVUZHLdXs0a3hoo6be+DFET9UBq7UPVMeBaTCT+wZ\nXzPnHFmBiBpiz1JcJPK7jHUe3Y5VZzh4d8PGCENmTIwdU4FdASDCJnt5/nmQgLir\nZLLGG3obPGUrNxplR5mXgMlJ7IQrjQOdi3tJeyt9ovfQDhJshSNsmhAxAoGBALTW\n4dLqvBulWL6YBzh9c6zEZpJRRAfYexsOYiSgw+h1BHwYCHy8uKKC2gP13wgBOllO\nr6B7MmPKcfh8fw0dThB6wHsj2Jg3K7dmKh/2EOOoNYEytHdR5qMQx2WM0H2S8bB/\nE28Ov4kNG+jfJmyhMj6hNxqATURmg2wJcZzWCWyRAoGAOPsrKFyIOUIWucZ4Idtz\n3oCO2GxpswZgRSUFg2u+70wBCUdYAA/7pLFUku7n2h850StNfobNJPxhXwEMOTsp\nmv6xaBPU15Qzxc1Y5zpuNdGl8Kdc5JyJZegynXo/7RgUEPI4sS4iW0A+QEz30nTp\nYB74ztSH6vJzOmCSTChAyrk=\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIENTCCAx2gAwIBAgIUXHwNTOaOOaNxE3pS6NXk2jXL4BgwDQYJKoZIhvcNAQEL\nBQAwgaQxCzAJBgNVBAYTAk1HMRgwFgYDVQQIDA9IYXV0ZSBtYXRzaWF0cmExFjAU\nBgNVBAcMDUZpYW5hcmFudHNvYSAxDDAKBgNVBAoMA0VuaTESMBAGA1UECwwJU2Vj\ndXJpdHkgMRcwFQYDVQQDDA5sb2NhbC5wcm9qZWN0MjEoMCYGCSqGSIb3DQEJARYZ\naGFuaXRyYWNsYXVkaW5lQGdtYWlsLmNvbTAeFw0yNjA1MDEwNTUxMzBaFw0yNzA1\nMDEwNTUxMzBaMIGkMQswCQYDVQQGEwJNRzEYMBYGA1UECAwPSGF1dGUgbWF0c2lh\ndHJhMRYwFAYDVQQHDA1GaWFuYXJhbnRzb2EgMQwwCgYDVQQKDANFbmkxEjAQBgNV\nBAsMCVNlY3VyaXR5IDEXMBUGA1UEAwwObG9jYWwucHJvamVjdDIxKDAmBgkqhkiG\n9w0BCQEWGWhhbml0cmFjbGF1ZGluZUBnbWFpbC5jb20wggEiMA0GCSqGSIb3DQEB\nAQUAA4IBDwAwggEKAoIBAQDdMhF6RhvKZBtbFZ3BYQSXvhG9FcUJb8/dFdC0DDCn\n/RSzOrSoCyYFwhPFSeFvEm9TNJMDNkHMt3vUAqkWAYFV0+pFK7lkNVZ/hIPjSSYR\na48otvxQBvC7k7sI9pXD0ILUQvKgSnXCRd00szcohmR7QbIk+JZcAsfr/Wyp3RRz\nG13QTWFtrscOy7Ibu7EclMv+T7W1wex8hbpe7TlPZGftcoIynCHDpbIG/FJFWrVS\nh5m+6QRVqEaQ4ChZh3jFjn2QnXf7o1xMruySey2Udvg571KBq27H+kZEQ7Mi9+ZX\n/PP3XJxkTYjj+8oAtP8jTw/ZK1u/hUxYbl6hq7Eyek6XAgMBAAGjXTBbMB0GA1Ud\nDgQWBBRj0xC9LgoRneY79hY0vRw275Uh1TAPBgNVHRMBAf8EBTADAQH/MA4GA1Ud\nDwEB/wQEAwIBhjAZBgNVHREEEjAQgg5sb2NhbC5wcm9qZWN0MjANBgkqhkiG9w0B\nAQsFAAOCAQEA1+G357hJj9G3WC7msV7Y1J7CHfVC+lgdJ+DMkutvVvKEVwC9fQTT\nfl6yVYKKyVivIZHC4D40bUX9aiqfx5BenVSQTfmCqYnfH+LUAI3UqtTkFn1I9ZAQ\nKYP8s8LZJ7ajA7bMANOcxvAQGwK9gE+GB6n+4euR2FDAvsIjh0mXaN1Gqy0wWdx6\nv96pF9eSlNcPzHu9bRyFmnuNQGHsyrHxIRiat0UuRcuPbf88Y6Bh2Y+3tjUomwKu\n/ALxBDc+ZMAkn3wvj0Aj6lDu03S9IiNzH7NqTkQs8AFbcuBeAfCcyaa0kTc/TQex\nUMC+WsxxM1StrTLUxFF+/q4PdFYKUPTNig==\n-----END CERTIFICATE-----\n	2027-05-01 05:51:30	VALID	C=MG, ST=Haute matsiatra, L=Fianarantsoa , O=Eni, OU=Security , CN=local.project2, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=Haute matsiatra, L=Fianarantsoa , O=Eni, OU=Security , CN=local.project2, emailAddress=hanitraclaudine@gmail.com	5C7C0D4CE68E39A371137A52E8D5E4DA35CBE018	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777614689984-z621yc/test2.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777614689984-z621yc/test2.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777614689984-z621yc/test2.srl	pem
9	intermtest	INTERMEDIATE	2026-05-01 09:48:09.803466	7	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDiloPXweYomolP\nBzI/E9RU87jDvX0leSbHPHZM8Og6sE0o+3848mqjkoVSq71AMaERb/+hJEZf2+3E\nlimxuGQG8r6J1WDnhbApa0Xdar+9aF/LiW6IWohNFE5v2RD9d+2yIr1wxR8CQJYO\n/17hnH55L5/YCuq3cpNKtfRKCqWY9YKfAyEJlBvt43MdLwxANpCJsOQOi81KtoL8\nrfVX8ytX6wHiSstTeldQoEmdc1NMwKEekNKNENeX8ZO30jfT6yubBGK97TGOefSC\nGwHuz5SbrNFx8FBkI5iajjtPdUxmikCbQRZzO/cRdEGHZj337FVwTvGtoJjqcCbS\nZTJ+5M91AgMBAAECggEAOft/OH5/SaOmAGmcg4StAKIvhTNfq2+xqyk/MpgxLReB\nXzvgRe/OtxXe9RVKg/tPNrmcxh0UvyH12aj9eWNwgVCrznSibAyLVEYFpk/TSgJE\nBT8hYFYea+8G1VtMHDiMxFlcddeThE2HuMXDf2M+//7eXfgJMTFqHKOsJChOUPIC\n/z5aIEbt6S9U5nzofyqw0iXKtikhDZCvklAYNK+uUGqTpdesJZHTRiTSUJTS6vVn\nBeNgp4kqyxwOJZw0oqbWpiE0zTevuVQsVY7r3mCLkVqsNNh5L1MDjwFQkGo7aKQy\nG3BiUqkASTwoA9yGmwUxUO2UnP/oFJZBD7vUik9P7wKBgQD7WTQUA/oN1HYOoMLU\niocTf0zsgy0o4aSaCgYv7P06S/OyHTwmUqwDwfG5V2Vps+noI31QGDio08iK2PGI\nEKuVojjFI9tQ7Y9N09jlovHhen29SoazZmuLFbPu3cuo2c/1w97r0hPaWOVi6cb/\nPVf13524hAfPRBIEFkk0ZTEdDwKBgQDmyAFjjIrqxFg94E+/sigNAZ58s2tqaoYs\nSAeHEGVSaZRoykfRw4aD2yCGOSNcFFeYxmf8Il71hrqgmefNzG49CAoiUtv4aTtY\ntDz5mjEIGmzuYXRf4ZM4a7DDArZ8qhC0Ab5iqpH3q16+QPyDmnUqrZkS1rc7eQK2\nQUY75+UTOwKBgDXlceJc2/C9Pzdxx3VV4xMOOAt7MWLTx7z0K1F5iu9GPBJUbIJ3\nNcV0gAXTNL7Ownhxq7xSBUxGZXlIfbpEgNaMO4oiXzPiTNlOdPMA1scXwgCmC25K\npwLi+3tb+gDR++LiRlng6Trn1wA3yuEOYV8qvSJExXvvR8Gyma3viPGHAoGBAJ2G\nm9wVjKUfDJR/zi+tLcVi+4lm9sUWnSsQp4K74E1Wn+S/XjKCYgkSw6qaydYKVJiF\npWjnFSZGppEFPMKu7fheynwPTvLK8aVksdI2O42qa/xzLPpdgR4b8/XInkON2gTk\nw82ZXDVQFkWLGlHCVoOhJ0FCqqO/v+gjugseCLENAoGBANQb5miehrI39aEBRMCc\nsNcuw3PhhCL4VlaCud39QCWDisfjC44erH+MnupHFs+4hsNtwabHlDuPPdK9Tinq\n0f/rDBgKUcepa3XCynR4lRYY42x17dmM8/gEH2tUxyoiXZpX4q8HiJLPfYXPc0wj\nYsWKETJEFpJJRgfHuKqCGGt9\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIEVDCCAzygAwIBAgIUCjs1Se/mt4kkVIh+afEuDECXvoAwDQYJKoZIhvcNAQEL\nBQAwgaMxCzAJBgNVBAYTAk1HMRgwFgYDVQQIDA9IYXV0ZSBtYXRzaWF0cmExFjAU\nBgNVBAcMDUZpYW5hcmFudHNvYSAxDDAKBgNVBAoMA0VuaTESMBAGA1UECwwJU2Vj\ndXJpdHkgMRYwFAYDVQQDDA1sb2NhbC5wcm9qZWN0MSgwJgYJKoZIhvcNAQkBFhlo\nYW5pdHJhY2xhdWRpbmVAZ21haWwuY29tMB4XDTI2MDUwMTA2NDgwOVoXDTI2MDYw\nNjA2NDgwOVowgaAxCzAJBgNVBAYTAk1HMRkwFwYDVQQIDBBIYXV0ZSBtYXRzaWF0\ncmEgMRYwFAYDVQQHDA1GaWFuYXJhbnRzb2EgMQwwCgYDVQQKDANFbmkxDjAMBgNV\nBAsMBUluZnJhMRYwFAYDVQQDDA1pbnRlcm1wcm9qZWN0MSgwJgYJKoZIhvcNAQkB\nFhloYW5pdHJhY2xhdWRpbmVAZ21haWwuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOC\nAQ8AMIIBCgKCAQEA4paD18HmKJqJTwcyPxPUVPO4w719JXkmxzx2TPDoOrBNKPt/\nOPJqo5KFUqu9QDGhEW//oSRGX9vtxJYpsbhkBvK+idVg54WwKWtF3Wq/vWhfy4lu\niFqITRROb9kQ/XftsiK9cMUfAkCWDv9e4Zx+eS+f2Arqt3KTSrX0SgqlmPWCnwMh\nCZQb7eNzHS8MQDaQibDkDovNSraC/K31V/MrV+sB4krLU3pXUKBJnXNTTMChHpDS\njRDXl/GTt9I30+srmwRive0xjnn0ghsB7s+Um6zRcfBQZCOYmo47T3VMZopAm0EW\nczv3EXRBh2Y99+xVcE7xraCY6nAm0mUyfuTPdQIDAQABo4GAMH4wHQYDVR0OBBYE\nFIBAm0Nil0R/AzaDc6eJqOiuWPP0MB8GA1UdIwQYMBaAFMMtRT+wje/Lkw7wDfjA\n3zkZ94mxMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBgGA1Ud\nEQQRMA+CDWludGVybXByb2plY3QwDQYJKoZIhvcNAQELBQADggEBAGisjqKLnc6z\nSlKlbB7cVJ8jeNhhU73i56fgfE5Jl2dxBfK0v1mVR+1rncMp6EY8AFdYP1DZyGsT\n0ddbvs7YQDMklHy/vKf8iZQ4snTa+eARVjWopjYH8zH3qdGJeAWD/vAcKp7DWn6X\nbOqwbhnnBALxM+UzU1V1RDlz8LKpPbcApTVAUDNgTRH1knNtvnoU7e3ysjsGhzFS\nOAsgPiTWo3m1fa2h43G5bo1F24lHRYXEMmjnUqNG+vH0cCVdBuDSQukTWYk7juHM\nGgelkvSyBOKB9a1jvmMMcuai/9VsKjjWMZM5fqPrQ5a0jTqF5vMPkHrAAxsBm5Ut\nLZu0wXqeaA0=\n-----END CERTIFICATE-----\n	2026-06-06 06:48:09	VALID	C=MG, ST=Haute matsiatra , L=Fianarantsoa , O=Eni, OU=Infra, CN=intermproject, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=Haute matsiatra, L=Fianarantsoa , O=Eni, OU=Security , CN=local.project, emailAddress=hanitraclaudine@gmail.com	0A3B3549EFE6B7892454887E69F12E0C4097BE80	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/intermediate-ca-1777618089644-sxmgaa/intermtest.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/intermediate-ca-1777618089644-sxmgaa/intermtest.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/intermediate-ca-1777618089644-sxmgaa/intermtest.srl	pem
10	test2	ROOT	2026-05-01 10:34:50.390009	\N	-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCx7UAV67JnDipM\n3F1LBzpj/n8MYRJhYGQJggX94IN18L87qSlqpYMrFIKRVIWcjJMu4kwQ+oGhtbrC\nP0MuSUkwCO49EJToRIx7BoN+QBoRCsZDA59LSHz4yn6kINTOsKrzcc7ird9OE1CT\nbWZLZ/7ftAv17cvJgPJQifaFQv1jk6FQwpQGfB4rioXnl4w30jtioEqYGsmNuEU5\nI57TgJ3b3fxIgDCRzNTyT6OENJxWAB+g6fcjeSP848IHJqRnu9vnK/8w8bRQmUcf\n1DPlSOkctztaAp4uicdSDgRaGN3mye4lDpDrcPl0Yf/dgaRwVkRW3N4A+5eLSy12\nzE8t5eZHAgMBAAECggEAGszZM9QSRbqY/YXN2aDHl0s8uNEgUyGRP+thWqnIM2ol\na+ehkOpIVSNcPWbFT1zPSKcWfRI2l3SHon2j8WNhjkYyGGmYfFni7R8AjHI8WufM\nEEkJ4+2RwWnC5Jb7Zvyua0fvuS4mbhyzrNk0KNSLzAdTK+J7KSlulloJk24RO7++\npOhSGON3kOw5ACy1JSsavFoYSEnalWXn8KM5hOFahg2b6IPhDyx4ednrlZlbMNB/\nH2dphNjpa+TeTU/uH7F6owcDzqizPYiJYhwunHx5Y0aDAGhRzWHzF8KBm+EA8v5x\nKNC13zqieCTShErxGb1uv89MTnYMH5NR+lNwWik9XQKBgQDyFhcf4SsAmoia6YyL\nZS53OF0hefj384rpm72/AhQzxMdK+fTHIifrzofKM5P54aSIl/EVIEKFfOAXjajY\nonBONNwbphRGVSYdkPfY1XAOaWoBHiaFtAGNQztRE+V4+I0QbdtHejRM0sJPdshQ\nZy2mvbszHFSeBbShBuaNrogb6wKBgQC8JyfoPlPq3quJSqGkIK3onYo9enNvGeyy\nkV+lcIpKwJW6Q3awc/LFeSSCkVhtzjzPEP9k5BG/gVEBuOe1gPipjHVkgQKYNV1U\nJkvWRDDtRmxuUqWQxxfvvaLvRhTFhN+yadT2e8QHGu6S5jMqV+dyFsA7vJAwrbv0\ntfv2ipfUFQKBgQDBtRtbzvhxyzVzf12OTLAZhWg/2TF2ddG5i30Q0cEIi3RMciWD\nEbmP3fqZuRu23u6gvbOSi/WuinVlY1yvu4rRiUp2dTXT8V5GWjF3t5Gqdn7z1gRN\nB/QV7K4R+jGr0nZNpxnG3+npbts8andunqDQwxB/nTO4HiiikLr6s6UFcQKBgQCw\nYdCSciN/EYEjMjh3wT7myxD18x3VsCrpd0h/shGiZAm41FemsPuMTbWBRTntriHp\nR5jz/q34pgTHpYxp5V62qvq93gcNozE7mq8LTV/Ef3lUrtuQ7mMtFsxwnHUKeTav\nbXD8JCgvNPsj8PNUJZXNqTBKj8loKOYDULrEc0ZDxQKBgQC4M4IFIpmlI4xwJj3Y\nmwoSeT6mATkth0T2zOnQWX9sW60P+z86P3hS5fYRWnSLRpLvClRgC6HxKATbCoc7\n7Hk5jNWi2hGo+H+WuFQTC8XYUDoW9vMnMq9x2D6LdJOS5bPk22yvIlm3CQihSHqA\n2UypjX/rVdL6P7vqRS6nLPsxtA==\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIENTCCAx2gAwIBAgIUcPHP9jusJ+vQ6Jn56XPecijLY4IwDQYJKoZIhvcNAQEL\nBQAwgaQxCzAJBgNVBAYTAk1HMRgwFgYDVQQIDA9IYXV0ZSBtYXRzaWF0cmExFjAU\nBgNVBAcMDUZpYW5hcmFudHNvYSAxDDAKBgNVBAoMA0VuaTESMBAGA1UECwwJU2Vj\ndXJpdHkgMRcwFQYDVQQDDA5sb2NhbC5wcm9qZWN0MjEoMCYGCSqGSIb3DQEJARYZ\naGFuaXRyYWNsYXVkaW5lQGdtYWlsLmNvbTAeFw0yNjA1MDEwNzM0NTBaFw0yNzA1\nMDEwNzM0NTBaMIGkMQswCQYDVQQGEwJNRzEYMBYGA1UECAwPSGF1dGUgbWF0c2lh\ndHJhMRYwFAYDVQQHDA1GaWFuYXJhbnRzb2EgMQwwCgYDVQQKDANFbmkxEjAQBgNV\nBAsMCVNlY3VyaXR5IDEXMBUGA1UEAwwObG9jYWwucHJvamVjdDIxKDAmBgkqhkiG\n9w0BCQEWGWhhbml0cmFjbGF1ZGluZUBnbWFpbC5jb20wggEiMA0GCSqGSIb3DQEB\nAQUAA4IBDwAwggEKAoIBAQCx7UAV67JnDipM3F1LBzpj/n8MYRJhYGQJggX94IN1\n8L87qSlqpYMrFIKRVIWcjJMu4kwQ+oGhtbrCP0MuSUkwCO49EJToRIx7BoN+QBoR\nCsZDA59LSHz4yn6kINTOsKrzcc7ird9OE1CTbWZLZ/7ftAv17cvJgPJQifaFQv1j\nk6FQwpQGfB4rioXnl4w30jtioEqYGsmNuEU5I57TgJ3b3fxIgDCRzNTyT6OENJxW\nAB+g6fcjeSP848IHJqRnu9vnK/8w8bRQmUcf1DPlSOkctztaAp4uicdSDgRaGN3m\nye4lDpDrcPl0Yf/dgaRwVkRW3N4A+5eLSy12zE8t5eZHAgMBAAGjXTBbMB0GA1Ud\nDgQWBBR/2JISzoDrg4IMcbPFUodxyXYjkzAPBgNVHRMBAf8EBTADAQH/MA4GA1Ud\nDwEB/wQEAwIBhjAZBgNVHREEEjAQgg5sb2NhbC5wcm9qZWN0MjANBgkqhkiG9w0B\nAQsFAAOCAQEACsrd81g+ofjnhaYGSzqmqdz0ndacXDJgGc03QxwFl77qFde7w4ay\n5fuPi9mNEiNAALr8AXzvbBvlLfBmwbb6Veyp88w9TALjRIgHgBLZz7XgYSpnzD1p\nrsibPZQMSB31eErN2/B2MCx4vTmaa3+kmfAfhvw0t1ysoz7w8EIkhlIKdav5KTPN\nE9b5+AtaGqBHaJk7uP2oiHuKWbsYAn2sT0JY4/ARhWPGikSjaI/9DMWX1G9cSLoY\ngZyl4Fl/iDfBmV4+wm/bDRRWVQnxe00rlt8vYl3FOE1zmlrAQXJ0DRPxYI2sqZOV\n4RXoHPyOkoUKQc51uiY5rw3rHI8TvVtkqg==\n-----END CERTIFICATE-----\n	2027-05-01 07:34:50	VALID	C=MG, ST=Haute matsiatra, L=Fianarantsoa , O=Eni, OU=Security , CN=local.project2, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=Haute matsiatra, L=Fianarantsoa , O=Eni, OU=Security , CN=local.project2, emailAddress=hanitraclaudine@gmail.com	70F1CFF63BAC27EBD0E899F9E973DE7228CB6382	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777620890229-33nxs4/test2.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777620890229-33nxs4/test2.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777620890229-33nxs4/test2.srl	pem
11	Ma Root CA importee	ROOT	2026-05-01 11:50:46.57571	\N	-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDEqXHormDc0aZT\nYNzDabjYy53ujCOG3qxOoGynE3NrTKy45iXK7pTO9aLKeW1hfouoWXkponY/IseL\ntvdA4GiEVzlHs2JKhdN3eFdgm1hLjMC78bZSb9+koNBrAs3nH116PYQANq9Dl9J/\nuj6O+AASE8a0HlyuUoBYsUl0QG3W/tSvvChFzvRRvg/8ts39DTWqlWqB006Ouj8X\nwPUOMVcj98X1RuXs42qu7lc/wl2QTxspp/OT1liTb4Vf+auC54Nrbho5Mm0Mo4u2\nUnFdnyztwHClcsesj0NtLnELOX02CzeH3zFJCrJKa8OEoNSJp0lDtgLh+d36YptK\nFbB6Dgs1AgMBAAECggEAKpgyqj1ekGU+G4/+sLpsxVPwrHKg3TzMYClB7zv4wzQz\nssZySA49n8e3DxiWtseUUw2x/vEHoGwVgS7LRbt1F7jWmK+DKfXrU9R2RF/RE2f0\ndKCJJzjA3STRj2PnmdgCxI+fT/aIJmEzP+PkWc3gIgozft6Wn1ESKGOZr7qmr6pX\ngrE6iQsgKZThHfTzeZ/UT8cLxFHp/JvY1XFqeisW7n9KPR1r7M7xxtF3tsQCP03X\nofyDtY7r1C/k8RRPNAfZ0pgka9TbnCMLVVhm2752z7Gam5yV4L5OxiAJOtCKSf6P\n+W+AKlaIxFveXP3CA41lHMCw0ihxKY5Zu3TCAiRITwKBgQDyryKv5mhalTnRzHDb\nWdfAW3eC9956c7ELy7m7pJvb2Zlu1qr2/u3zt7BsYS17SskZogu4035TAnmylFA0\nesNJOJslJhXn0FTXBKDX/uSCXAPShV5nk22Npjj1uKfg4m3jClRC2EqAn02XC2hk\nEzFOCkCrd5goT1c7jyvTOHQGfwKBgQDPc9ucKuN2lQchJVoKSg45Unuh4Woh9oSL\nON7RZKZsgAcy/zKwPoPlU8H/US6USCxKjqHe+BjfqdXxp3hLyVCo2q2IupudgIEt\ngSzI2E6uB3jIMotKVTQUHHwrvr9vpNasYn/bIv9jJlmBYGSUi6URczqAHVb7YhCg\nQR9P5gXcSwKBgGiQybNc5a3SCn25Rw9cYLgDMTV/M58zZh+dAkQ1oupRkejOGhAe\nu8x9Y0jvfjdXe9rNlZtnlVCTCnjFquFR2/8aos6Y4GtnuoaC+gLXUwJQP11gFdMv\nFM8pxfUqQTuGlK507uV2aHOPMFFamvozwtTLWh4Hg8oqlX2WLN3vvx5lAoGAFTvS\nmqV5KsYOOMJN+QejdRKQPP2Jk3hcELP9eolGz4w7MGkWkxuS/IIaNTvl/J92iRsY\nTm4ufZYwo890bK1qaB4Z7QjMrM5ean3yS4x4YS+6mSMzRqR59CUGQKQBjDffET3z\nwEZQxaFDQA7RvLKebq7QqhRWttxOv1hrEA6HQwkCgYEAmr+73LoWbx5HSyd3Zc3S\nyxJuNBA7RytT/SKRXcr0ZKt5vlNsmkQEZrE5epz5U9U6nhMNNZIls9/dngmvHJNF\n1RpPoOQ1hu5lrWKc6A6hOlItxngoIY33Tmiywo5QAJUpskgiIQbOxzeIEwhLNV7C\nV62hoasI5sc85QrDbb+FMZU=\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIEATCCAumgAwIBAgIUOl7YJqh3g/0abiaHSOxopZv6NM0wDQYJKoZIhvcNAQEL\nBQAwgY8xCzAJBgNVBAYTAk1HMRUwEwYDVQQIDAxGSUFOQVJBTlRTT0ExETAPBgNV\nBAcMCFRhbmFtYmFvMQwwCgYDVQQKDANFTkkxCzAJBgNVBAsMAkwzMREwDwYDVQQD\nDAhNeVJvb3RDQTEoMCYGCSqGSIb3DQEJARYZaGFuaXRyYWNsYXVkaW5lQGdtYWls\nLmNvbTAeFw0yNjA0MTgxNTI1MTZaFw0yNzA0MTgxNTI1MTZaMIGPMQswCQYDVQQG\nEwJNRzEVMBMGA1UECAwMRklBTkFSQU5UU09BMREwDwYDVQQHDAhUYW5hbWJhbzEM\nMAoGA1UECgwDRU5JMQswCQYDVQQLDAJMMzERMA8GA1UEAwwITXlSb290Q0ExKDAm\nBgkqhkiG9w0BCQEWGWhhbml0cmFjbGF1ZGluZUBnbWFpbC5jb20wggEiMA0GCSqG\nSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDEqXHormDc0aZTYNzDabjYy53ujCOG3qxO\noGynE3NrTKy45iXK7pTO9aLKeW1hfouoWXkponY/IseLtvdA4GiEVzlHs2JKhdN3\neFdgm1hLjMC78bZSb9+koNBrAs3nH116PYQANq9Dl9J/uj6O+AASE8a0HlyuUoBY\nsUl0QG3W/tSvvChFzvRRvg/8ts39DTWqlWqB006Ouj8XwPUOMVcj98X1RuXs42qu\n7lc/wl2QTxspp/OT1liTb4Vf+auC54Nrbho5Mm0Mo4u2UnFdnyztwHClcsesj0Nt\nLnELOX02CzeH3zFJCrJKa8OEoNSJp0lDtgLh+d36YptKFbB6Dgs1AgMBAAGjUzBR\nMB0GA1UdDgQWBBQpZbcAnGpjRowprAgJbRHxECds4jAfBgNVHSMEGDAWgBQpZbcA\nnGpjRowprAgJbRHxECds4jAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUA\nA4IBAQC0Yt3oN7IrpPx8Ge6H4qC+NtRUxEnOuYPxydyEvM+n2XCXKslmnIMCe+jJ\ndFfbLGU1ye3HlJM64+cyy+OK9FRgVYOUAUZNqhHRBvkzPs9vhJxILdUtL8JbU11j\nimHoJtzqQLLaDW1nDCfz2YsxL4HWi4NT/owpI2SGYvqjAQw5I3w0S3IkfC/doIZ9\nMBVacjlEeV62eqi7FF9yaZw75d5U9y5ZTNR5fFUh4/KAw6YoPenwlK3vho8b9hBJ\niJmdUKrRZrFy+QMb+em7E7v5Zb/Z5xxObDJcNBkTh4kNKoHtprtnwIJoCcRubM2b\n3AJTrcDmrGuGbSTKE97PusAxas+6\n-----END CERTIFICATE-----\n	2027-04-18 15:25:16	VALID	C=MG, ST=FIANARANTSOA, L=Tanambao, O=ENI, OU=L3, CN=MyRootCA, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=FIANARANTSOA, L=Tanambao, O=ENI, OU=L3, CN=MyRootCA, emailAddress=hanitraclaudine@gmail.com	3A5ED826A87783FD1A6E268748EC68A59BFA34CD	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/imported-ca-1777625446491-wutbhi/ma-root-ca-importee.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/imported-ca-1777625446491-wutbhi/ma-root-ca-importee.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/imported-ca-1777625446491-wutbhi/ma-root-ca-importee.srl	pem
12	Please	ROOT	2026-05-01 11:54:42.641378	\N	-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDEqXHormDc0aZT\nYNzDabjYy53ujCOG3qxOoGynE3NrTKy45iXK7pTO9aLKeW1hfouoWXkponY/IseL\ntvdA4GiEVzlHs2JKhdN3eFdgm1hLjMC78bZSb9+koNBrAs3nH116PYQANq9Dl9J/\nuj6O+AASE8a0HlyuUoBYsUl0QG3W/tSvvChFzvRRvg/8ts39DTWqlWqB006Ouj8X\nwPUOMVcj98X1RuXs42qu7lc/wl2QTxspp/OT1liTb4Vf+auC54Nrbho5Mm0Mo4u2\nUnFdnyztwHClcsesj0NtLnELOX02CzeH3zFJCrJKa8OEoNSJp0lDtgLh+d36YptK\nFbB6Dgs1AgMBAAECggEAKpgyqj1ekGU+G4/+sLpsxVPwrHKg3TzMYClB7zv4wzQz\nssZySA49n8e3DxiWtseUUw2x/vEHoGwVgS7LRbt1F7jWmK+DKfXrU9R2RF/RE2f0\ndKCJJzjA3STRj2PnmdgCxI+fT/aIJmEzP+PkWc3gIgozft6Wn1ESKGOZr7qmr6pX\ngrE6iQsgKZThHfTzeZ/UT8cLxFHp/JvY1XFqeisW7n9KPR1r7M7xxtF3tsQCP03X\nofyDtY7r1C/k8RRPNAfZ0pgka9TbnCMLVVhm2752z7Gam5yV4L5OxiAJOtCKSf6P\n+W+AKlaIxFveXP3CA41lHMCw0ihxKY5Zu3TCAiRITwKBgQDyryKv5mhalTnRzHDb\nWdfAW3eC9956c7ELy7m7pJvb2Zlu1qr2/u3zt7BsYS17SskZogu4035TAnmylFA0\nesNJOJslJhXn0FTXBKDX/uSCXAPShV5nk22Npjj1uKfg4m3jClRC2EqAn02XC2hk\nEzFOCkCrd5goT1c7jyvTOHQGfwKBgQDPc9ucKuN2lQchJVoKSg45Unuh4Woh9oSL\nON7RZKZsgAcy/zKwPoPlU8H/US6USCxKjqHe+BjfqdXxp3hLyVCo2q2IupudgIEt\ngSzI2E6uB3jIMotKVTQUHHwrvr9vpNasYn/bIv9jJlmBYGSUi6URczqAHVb7YhCg\nQR9P5gXcSwKBgGiQybNc5a3SCn25Rw9cYLgDMTV/M58zZh+dAkQ1oupRkejOGhAe\nu8x9Y0jvfjdXe9rNlZtnlVCTCnjFquFR2/8aos6Y4GtnuoaC+gLXUwJQP11gFdMv\nFM8pxfUqQTuGlK507uV2aHOPMFFamvozwtTLWh4Hg8oqlX2WLN3vvx5lAoGAFTvS\nmqV5KsYOOMJN+QejdRKQPP2Jk3hcELP9eolGz4w7MGkWkxuS/IIaNTvl/J92iRsY\nTm4ufZYwo890bK1qaB4Z7QjMrM5ean3yS4x4YS+6mSMzRqR59CUGQKQBjDffET3z\nwEZQxaFDQA7RvLKebq7QqhRWttxOv1hrEA6HQwkCgYEAmr+73LoWbx5HSyd3Zc3S\nyxJuNBA7RytT/SKRXcr0ZKt5vlNsmkQEZrE5epz5U9U6nhMNNZIls9/dngmvHJNF\n1RpPoOQ1hu5lrWKc6A6hOlItxngoIY33Tmiywo5QAJUpskgiIQbOxzeIEwhLNV7C\nV62hoasI5sc85QrDbb+FMZU=\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIEATCCAumgAwIBAgIUOl7YJqh3g/0abiaHSOxopZv6NM0wDQYJKoZIhvcNAQEL\nBQAwgY8xCzAJBgNVBAYTAk1HMRUwEwYDVQQIDAxGSUFOQVJBTlRTT0ExETAPBgNV\nBAcMCFRhbmFtYmFvMQwwCgYDVQQKDANFTkkxCzAJBgNVBAsMAkwzMREwDwYDVQQD\nDAhNeVJvb3RDQTEoMCYGCSqGSIb3DQEJARYZaGFuaXRyYWNsYXVkaW5lQGdtYWls\nLmNvbTAeFw0yNjA0MTgxNTI1MTZaFw0yNzA0MTgxNTI1MTZaMIGPMQswCQYDVQQG\nEwJNRzEVMBMGA1UECAwMRklBTkFSQU5UU09BMREwDwYDVQQHDAhUYW5hbWJhbzEM\nMAoGA1UECgwDRU5JMQswCQYDVQQLDAJMMzERMA8GA1UEAwwITXlSb290Q0ExKDAm\nBgkqhkiG9w0BCQEWGWhhbml0cmFjbGF1ZGluZUBnbWFpbC5jb20wggEiMA0GCSqG\nSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDEqXHormDc0aZTYNzDabjYy53ujCOG3qxO\noGynE3NrTKy45iXK7pTO9aLKeW1hfouoWXkponY/IseLtvdA4GiEVzlHs2JKhdN3\neFdgm1hLjMC78bZSb9+koNBrAs3nH116PYQANq9Dl9J/uj6O+AASE8a0HlyuUoBY\nsUl0QG3W/tSvvChFzvRRvg/8ts39DTWqlWqB006Ouj8XwPUOMVcj98X1RuXs42qu\n7lc/wl2QTxspp/OT1liTb4Vf+auC54Nrbho5Mm0Mo4u2UnFdnyztwHClcsesj0Nt\nLnELOX02CzeH3zFJCrJKa8OEoNSJp0lDtgLh+d36YptKFbB6Dgs1AgMBAAGjUzBR\nMB0GA1UdDgQWBBQpZbcAnGpjRowprAgJbRHxECds4jAfBgNVHSMEGDAWgBQpZbcA\nnGpjRowprAgJbRHxECds4jAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUA\nA4IBAQC0Yt3oN7IrpPx8Ge6H4qC+NtRUxEnOuYPxydyEvM+n2XCXKslmnIMCe+jJ\ndFfbLGU1ye3HlJM64+cyy+OK9FRgVYOUAUZNqhHRBvkzPs9vhJxILdUtL8JbU11j\nimHoJtzqQLLaDW1nDCfz2YsxL4HWi4NT/owpI2SGYvqjAQw5I3w0S3IkfC/doIZ9\nMBVacjlEeV62eqi7FF9yaZw75d5U9y5ZTNR5fFUh4/KAw6YoPenwlK3vho8b9hBJ\niJmdUKrRZrFy+QMb+em7E7v5Zb/Z5xxObDJcNBkTh4kNKoHtprtnwIJoCcRubM2b\n3AJTrcDmrGuGbSTKE97PusAxas+6\n-----END CERTIFICATE-----\n	2027-04-18 15:25:16	VALID	C=MG, ST=FIANARANTSOA, L=Tanambao, O=ENI, OU=L3, CN=MyRootCA, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=FIANARANTSOA, L=Tanambao, O=ENI, OU=L3, CN=MyRootCA, emailAddress=hanitraclaudine@gmail.com	3A5ED826A87783FD1A6E268748EC68A59BFA34CD	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/imported-ca-1777625682542-uqo2qs/please.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/imported-ca-1777625682542-uqo2qs/please.crt.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/imported-ca-1777625682542-uqo2qs/please.srl	pem
13	Lala	ROOT	2026-05-03 13:05:44.790732	\N	-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCGJ1F0YWt4RaRD\nsTi2ixQ5pOxvdzp59zw2IgRidugKOHYivGE/LnSmKshCpDE0JCZChYM4v7dxcdry\nNu7swiUS3MNrx2qTMClf2KyifEmMV5SIxN6racksvvCM6YgolH9fMg4SOwaPR7Ta\nFRExeuTZefmR20bJpKwI37CzU5RbutrFxdDrNCxO3LSYxN2AVJP1U89DAdhNmrSE\nxcfZVQigMPHIXKmY804IAgogeCdwc+6slh3Q8VEo5il6KouSd+K3hzRj8NxQJVty\nqfbA8JLjUKhQ4Maw/VNu6QQqGcer6B0HjT02u3M4tLJDvtKeRbf2sMEyx5IYnQ6F\n9+I4YX1NAgMBAAECggEAC53d/NDuyHRnXAE9ovj6IF+6pZBSfPs+uIVLkecwAqqO\n+EUNurXgHf94ZeTn6dbzhTEggsp/LRCp3+2H1PKe2TpKpcuX2/UAsC8IC+3tRHzU\n/N7nVTqM1BYYqGsUgkcRnIGuHEAGOmQAMh4+5eT5aieYx9uQDqf2ybHtECo9n4+3\nhd2EzjKwHKtTlfexWOC47sTf40AXDq09MWpN+pY8Kv1dnV9q8OrcgN9BxSRug+wA\nulRiSvEL/SIkfuRS8BLZqeSlWxpxQo3IclY0sdReefr1fhwX9PZFQOSxPSw21DjF\nRpLj8jPsM4LZoEGEXGyXSC0LlaghcUPS9R0cD2cz1QKBgQC9SnABpUEku5MUJqHU\nfpFIreVm2JkAbMCdnVY+jdXR81bjzKBrhpa3U7s9g/Su/L9V/ZZv4aBvgOT6lyix\nO890UHgFhgiSPo7egTyniaOsMzLldjWH20OfLnJzmt6in8M+gEKQpaK0OvWJXOo7\npmBbXqJxf4CwSoqDKKimKo562wKBgQC1bnoX0rc+o4HppXWpqdcPk37jeHCWnU8F\nU6HoE4FvXlYI/Oge1yQXgXLAry4XrL8T6NMsOn/MlOrHt+Pcwasx4FizjAqlmOqS\nxV68yXRQRmdQfzRJenUU9eYGnmmnNzJ4VqfNlUw+XNYo5Zsi/isdftMXr9yCBLBU\nYMeruTsc9wKBgFfHSA+LSZ02GqtSiuMWWlsAwQujT7hBtkSg7JiPf2Mf2+BBSPbz\n77pN6ttI8NOgwz2mHff+Aj8S35xRMn6VxMskcbPmBt2CgxAtkCoFCtBU4bpEyegZ\nRs9vY4W2gJ2bRpgaNEQNe1jmqmwrmTdWHQLh7KSDQvL9biQKW8LKo03XAoGAUIQC\nsufUYnv1f1bqbKzuv/7Y5OHiNTUCiH6g73kYi+/1hm+WI3mejr/nyRL1BZSoB5Hf\nhVVAue2sc41sFd/stWm2c5fGcc726sOkU2ujrqxP1S1eau1pYC/wMSfEA20/fKAY\nP+ftug9BC006F8FsKN7Ll0t4NEsYZZm9grvlO+kCgYAElxbjPSGky+HsirDDsD8m\nWhiRV59JwOS/CnWWTeUKZNR7hsVNDYuUqdQkV5Z2J2Wg77hII5fNOrzLbhwqge2R\nXGOe7rxTTrJQ//+6KOkQSzf1Movj0aeFIaa245n7vRNaxlGIPBwxazq/swh6boWD\nFe2BwhGED9SI+l7LJhg9aw==\n-----END PRIVATE KEY-----\n	-----BEGIN CERTIFICATE-----\nMIIEAzCCAuugAwIBAgIUIiKAyLERuq2BYFt5r6S7jwSp8yMwDQYJKoZIhvcNAQEL\nBQAwgZAxCzAJBgNVBAYTAk1HMRYwFAYDVQQIDA1GaWFuYXJhbnRzb2EgMRIwEAYD\nVQQHDAlUYW5hbWJhbyAxDTALBgNVBAoMBExhbGExDTALBgNVBAsMBExhbGExDTAL\nBgNVBAMMBExhbGExKDAmBgkqhkiG9w0BCQEWGWhhbml0cmFjbGF1ZGluZUBnbWFp\nbC5jb20wHhcNMjYwNTAzMTAwNTQ0WhcNMjcwNTAzMTAwNTQ0WjCBkDELMAkGA1UE\nBhMCTUcxFjAUBgNVBAgMDUZpYW5hcmFudHNvYSAxEjAQBgNVBAcMCVRhbmFtYmFv\nIDENMAsGA1UECgwETGFsYTENMAsGA1UECwwETGFsYTENMAsGA1UEAwwETGFsYTEo\nMCYGCSqGSIb3DQEJARYZaGFuaXRyYWNsYXVkaW5lQGdtYWlsLmNvbTCCASIwDQYJ\nKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIYnUXRha3hFpEOxOLaLFDmk7G93Onn3\nPDYiBGJ26Ao4diK8YT8udKYqyEKkMTQkJkKFgzi/t3Fx2vI27uzCJRLcw2vHapMw\nKV/YrKJ8SYxXlIjE3qtpySy+8IzpiCiUf18yDhI7Bo9HtNoVETF65Nl5+ZHbRsmk\nrAjfsLNTlFu62sXF0Os0LE7ctJjE3YBUk/VTz0MB2E2atITFx9lVCKAw8chcqZjz\nTggCCiB4J3Bz7qyWHdDxUSjmKXoqi5J34reHNGPw3FAlW3Kp9sDwkuNQqFDgxrD9\nU27pBCoZx6voHQeNPTa7czi0skO+0p5Ft/awwTLHkhidDoX34jhhfU0CAwEAAaNT\nMFEwHQYDVR0OBBYEFEVgRhaiEPx4Ep8pmBhs7EIL5ruhMA8GA1UdEwEB/wQFMAMB\nAf8wDgYDVR0PAQH/BAQDAgGGMA8GA1UdEQQIMAaCBExhbGEwDQYJKoZIhvcNAQEL\nBQADggEBADpO7lzHuBxGSfnqFe1kC/gJrSNky2Fmsnv2HIOp/zhgL6T859p33aW+\nIZhtlq9kSMtCHNOrWmjROzynhtQ1w+iua8OFgY8/7k/0kicMZUrzfYvetoh6T8WZ\n5jWnkFNI8HgTNy6fO6JWAF2nMpc0WY7iac3rxSZNKen9vqa2CWDagGlSMzcbW6Zm\nzgXU6p4w2VUdHmbGe/VXTk1/V8/6w7Os6nWe0wx1r+zYMKFSHpSP1UAaErP+Zutl\n5Np9ySZB6bIIkaeJwRsUky4aAxFdCMDx681mz2QNpXbWFG6pdEWq0qkp2wX4WqVm\n7UMxLo6Mmbo45LbpGyYl6Zwg4zZPOYo=\n-----END CERTIFICATE-----\n	2027-05-03 10:05:44	VALID	C=MG, ST=Fianarantsoa , L=Tanambao , O=Lala, OU=Lala, CN=Lala, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=Fianarantsoa , L=Tanambao , O=Lala, OU=Lala, CN=Lala, emailAddress=hanitraclaudine@gmail.com	222280C8B111BAAD81605B79AFA4BB8F04A9F323	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777802744602-vhjnhx/lala.key	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777802744602-vhjnhx/lala.crt	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/cas/root-ca-1777802744602-vhjnhx/lala.srl	pem
\.


--
-- Data for Name: certificate_sans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.certificate_sans (san_id, certificate_id, domain) FROM stdin;
1	1	api-1777600235628.techmobile.local
2	1	*.1777600235628.techmobile.local
3	2	api-1777600262376.techmobile.local
4	2	*.1777600262376.techmobile.local
5	3	generatedcsr
6	3	exemple.domaine
\.


--
-- Data for Name: certificate_signing_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.certificate_signing_requests (csr_id, common_name, algorithm, created_at, status, subject_dn, csr, private_key, csr_path, key_path, source_format, signed_certificate_id, ca_id) FROM stdin;
1	api-1777600163380.techmobile.local	rsaEncryption	2026-05-01 04:49:23.632675	PENDING	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=Platform, CN=api-1777600163380.techmobile.local, emailAddress=ops@techmobile.local	-----BEGIN CERTIFICATE REQUEST-----\nMIIDuDCCAqACAQAwgbMxCzAJBgNVBAYTAk1HMRMwEQYDVQQIDApBbmFsYW1hbmdh\nMRUwEwYDVQQHDAxBbnRhbmFuYXJpdm8xEzARBgNVBAoMClRlY2hNb2JpbGUxETAP\nBgNVBAsMCFBsYXRmb3JtMSswKQYDVQQDDCJhcGktMTc3NzYwMDE2MzM4MC50ZWNo\nbW9iaWxlLmxvY2FsMSMwIQYJKoZIhvcNAQkBFhRvcHNAdGVjaG1vYmlsZS5sb2Nh\nbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANYe2VsIsFz/2XXMlhFX\nQwN0EZQfcnpn4tQuM+wWouHMglohhmv19C9iDJ7k5D9knfN9VaYOnSYptpwOpgrZ\nrJxPpJ/gN2E7nqwSvSZttVHls4bodCMUNOB+6NgDSw0uvTBVGIdq6qpz4zstGlY1\nX80JZ1Al125QVyb9ICiLE2CSmC0Mj7iqb/4zlFla5BjZPdlNVi3fF5eV92jxtryA\nfLmOomyh1GkgLxrg3OE4MPcrAquiTyD2yQcpJpNHwd9RWLw3RKUB3UjjjvCqu+W2\n/TTdLoDbP7iZLuEEfqyI/wJRDOvBRu7UpIUQ/MlAndR25tkilf0DiqNr328f2V3m\nIFkCAwEAAaCBvjCBuwYJKoZIhvcNAQkOMYGtMIGqMB0GA1UdDgQWBBQq0b6iYwVD\nPQmTHY/+Hck/DLk1hzAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUE\nFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwTwYDVR0RBEgwRoIiYXBpLTE3Nzc2MDAx\nNjMzODAudGVjaG1vYmlsZS5sb2NhbIIgKi4xNzc3NjAwMTYzMzgwLnRlY2htb2Jp\nbGUubG9jYWwwDQYJKoZIhvcNAQELBQADggEBAAbJLK0dDo1i+zijpUjdgpeibf6q\nqs6IEnxggaE/iaSNDbyuHXFct6h/tWkpHpRZ01hEI8eW5KGaLNeUlX1FY8jVjG3r\n/QVu1VxHviXy4b2uafqwHZXCqPmWNTPzib1a51jQnRzPYFHFbcTuiT+om8M8hucw\nOw99SvJTZ311HWndJDTtwg5otqQ7zRKLJ/Fl0Ill/ejjgYu91zJ5/6bpm7hIhS/w\nbOgAG31uuGv62bc5qOvkZ6OFkjj8410YkhBL7oqEAPEqPI8tKTGZrFFH0e8E8ur8\nHkp2ynqEZS2UCCQaxq7kpf1HqYpQQBDy6nJH7Jwlv65yvyeX6B/E7w2GJZs=\n-----END CERTIFICATE REQUEST-----\n	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDWHtlbCLBc/9l1\nzJYRV0MDdBGUH3J6Z+LULjPsFqLhzIJaIYZr9fQvYgye5OQ/ZJ3zfVWmDp0mKbac\nDqYK2aycT6Sf4DdhO56sEr0mbbVR5bOG6HQjFDTgfujYA0sNLr0wVRiHauqqc+M7\nLRpWNV/NCWdQJdduUFcm/SAoixNgkpgtDI+4qm/+M5RZWuQY2T3ZTVYt3xeXlfdo\n8ba8gHy5jqJsodRpIC8a4NzhODD3KwKrok8g9skHKSaTR8HfUVi8N0SlAd1I447w\nqrvltv003S6A2z+4mS7hBH6siP8CUQzrwUbu1KSFEPzJQJ3UdubZIpX9A4qja99v\nH9ld5iBZAgMBAAECggEAN0uTLRey1+l4opu5W3QSCcfFLF/so+DFKq9d2EfGO5Kh\nTR5gROwo6b2j7brFmPtmcPV6k14txie6kVWVGrM5CMrmhCUWmCUZ5m0WbOCjFSnB\nMYNBTrfOqfUMM5CyJo7d66fmJD5/qJIx6dvNc9rnyR73D7MeDc5wm1B+KAo2cFci\nP5SVkXK5JxQqLzU+KL14uZl1NUvZi0SblCbg00E3E9HwhMgXZ9ag2IggGxEJsEl9\n7ODx3MYx4eZG3gxU+WjzfemYiNHuWxJiVbPDPY/rNULpPJfviWe8MKhbweqkbsiX\ncG0xS/UCwqNgkt/A2zXSg2h9SPUq+2nMkX6gd0EaiwKBgQDwMEyWzQghY5Fs/kO6\nCkUM9cG+848iKoTkCKVtYRbadpghGoslqNOAkULGh2O79ONNZVm6UDCanaqjmh34\nLujak+QYLWeN3T+lO6uPi45Si/+Cm2gTeSBM9GtjdmK5FPhm70M3iJVU5AGVn0xS\nRejiojHb0NyB4C9PN1twjAnyRwKBgQDkNz6inlnSXLAJEWPguALDN3oISIHYvtAY\nwdDjlGwC2w35wCLbMUKPSOqfb1gvgAEz3bJecRnwbJ9ztrwAxErcybAQMq6CI03a\n3fqsk/Pw3T7VV2oFB1PzcRYCshftrPRcELTSCdxQzoTvtcYqOD47IjXKJXW+R+7H\nNidCKsUIXwKBgQCJ4dA1yaHfOP9k6FoM1JRrKjF84ujKHkqHdYcx0UiDRQ10A37Z\nsZ8o8Tq6KULRxXUvGv11fU9JkzVAEdsefB9kSv3n+zi1Mcu1mRmVn/Gl5YRaf8gx\nVZl7U9zKDk4CHc2zmaqmmJvRTcqzD+2KVWOppp6kp7POQtolyYuOgnW7RQKBgE0m\nK+N3mq/Vq6D1IwmVy0FJYNSqBlNKdjjYVJCK3VS9zuSuQlpNNc4QfVh2oJ42LLHm\n8WSh4X34ipLopHex5AjtmbpwF7Rg0PH7dsGepqm3cYVXrrySdJvoj+NLZ3FutZDm\nCOq0cKlUl3YdwicFqmv9Lafvr/UqhhsMQItKwB8LAoGBAMCWd0c9IbAFMsK41sC6\nDpd1MS8gJhW8EBoOchBBesyBAqqCdu1rNM1Axc673Ta6Kdlmo1FylzIKq5pz7y42\nxAPPZCWFHQ27WcvSJUL9QVCbvfaMDsJLf/f83rkyn7/Rrq3IDjiLnVvkWn8deRUo\noCNEykO5fvbskDHs5HsVRDnF\n-----END PRIVATE KEY-----\n	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600163551-kzoxy2/api-1777600163380.techmobile.local.csr.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600163551-kzoxy2/api-1777600163380.techmobile.local.key.pem	pem	\N	\N
2	api-1777600235628.techmobile.local	RSA_2048	2026-05-01 04:50:35.993974	SIGNED	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=Platform, CN=api-1777600235628.techmobile.local, emailAddress=ops@techmobile.local	-----BEGIN CERTIFICATE REQUEST-----\nMIIDuDCCAqACAQAwgbMxCzAJBgNVBAYTAk1HMRMwEQYDVQQIDApBbmFsYW1hbmdh\nMRUwEwYDVQQHDAxBbnRhbmFuYXJpdm8xEzARBgNVBAoMClRlY2hNb2JpbGUxETAP\nBgNVBAsMCFBsYXRmb3JtMSswKQYDVQQDDCJhcGktMTc3NzYwMDIzNTYyOC50ZWNo\nbW9iaWxlLmxvY2FsMSMwIQYJKoZIhvcNAQkBFhRvcHNAdGVjaG1vYmlsZS5sb2Nh\nbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALHkoePyGvrXXJrRfGhy\nW4ESYbxDbN+KY9vyDS+HkaGtXiSUSqcCFrwnyiScangeEQ+7BPFuwq3n4jdlDNYF\ntqPaa3nMI2U6R43B/DZ0NTELczeUwpWcX8ls7P+BkuwF87mQyM8ZtbfJZgaMwUP3\nlxCKu0/2wCbTRM9P+m9LPSRFf4TofgLhdET6PQJ6Nnepe9Y1oAe9jjIT8zj5MENT\nwhd3CnvLU5dPOwbu7ERVG5oVpiLX7gJt2NQXZ++M1xB8aiSHAAZ6kYBd2//vXVL8\nrUKoQc4cz5u2IRyyflLC18UobaWS7gX2KnW8CnlF+zDCHiXXVBOYISzfhSXtEjHj\nU5sCAwEAAaCBvjCBuwYJKoZIhvcNAQkOMYGtMIGqMB0GA1UdDgQWBBSdUFSwWPBS\nurH++epoNHvvRxMlCjAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUE\nFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwTwYDVR0RBEgwRoIiYXBpLTE3Nzc2MDAy\nMzU2MjgudGVjaG1vYmlsZS5sb2NhbIIgKi4xNzc3NjAwMjM1NjI4LnRlY2htb2Jp\nbGUubG9jYWwwDQYJKoZIhvcNAQELBQADggEBAKwq0+Qb+xfTb+aSu0JsygqN+XRZ\nL2Tf7oalWEpf8+3/jz2WGnnhGcbf0qC3Ga9uSfjrpHff6bsPmXIkgUy/ryzjbBr5\n2Ni0ce5pH6cr2N+FZdLEk7NFv08hhvcQhCPlAOemFC0C0JIOOOpJulJCqf4Mgbs9\noEDPBMpI24A1LlMqdU2Ecla8AHdUaGfaS4HIZNKPCuC+1OeAbRKCR+3alSTuWDvG\nMVkdPDqPKP2fw9btnzY8ZJ1qp/3TbzyNvkFD6hILFb6wxgUfh21bpLbdG74oalxq\nZt8vqlyUsm5hcnjpmDLtgF2I/UrFh2cDlxP4o+lgaq0bwc30gJwnyzfbXRU=\n-----END CERTIFICATE REQUEST-----\n	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCx5KHj8hr611ya\n0XxocluBEmG8Q2zfimPb8g0vh5GhrV4klEqnAha8J8oknGp4HhEPuwTxbsKt5+I3\nZQzWBbaj2mt5zCNlOkeNwfw2dDUxC3M3lMKVnF/JbOz/gZLsBfO5kMjPGbW3yWYG\njMFD95cQirtP9sAm00TPT/pvSz0kRX+E6H4C4XRE+j0CejZ3qXvWNaAHvY4yE/M4\n+TBDU8IXdwp7y1OXTzsG7uxEVRuaFaYi1+4CbdjUF2fvjNcQfGokhwAGepGAXdv/\n711S/K1CqEHOHM+btiEcsn5SwtfFKG2lku4F9ip1vAp5Rfswwh4l11QTmCEs34Ul\n7RIx41ObAgMBAAECggEAIG4hU0hiQcN8Jt800meypcuflK4oDXKRtNmiLL2Gv5Y2\n+O0t1NdtJJ0OXXFEeaRlkNwT0R3TkNeapmWeGvBMtP9PI5OjCkO/IqkwHQ8/WTMQ\nrJvKg3LQBYz9gbDyA2QsY/JwoUy7E4e8OUp0uzrKR+I6tp+xtQJD45VdfueU/GT/\nNKDhlYhXN6rV0bauZVYdf+sxvce1keYULghgUYHprtQvrG3f3FRuCWCBgbpGqstS\nwJCpoge4EfS4t0f7hAxFPYHWYfkDwf5dmOrMvxEb39A2ElcPkDnfnPnopdYnb9AX\nQwlEtsoxXdCO1b5Ak4ECPuizdRUcaIX684WffgE/yQKBgQDeMS4EH7JKf3btSc2J\npXiNhGK0HPl/z378qZgNghLR8IgwEIUVQu9Rgp2doyKm8r95efyg9GUmyf03GgEs\nWSTVgXeeCvJr3BL4ZasDs3Gx4Egpkw6UEkvpxXdVWL1TsCKEADkd6dBGO+W9EsBf\nXxckj1B+3czpR4U4UFjVQ6BvcwKBgQDM9es32d101JX0CKwokqCiQLXR9W1HnU9w\n+HejK3vxtglbwtiH121ZjW8VIsVymxoaRw34xyrF6Mmkh5Qy/eJ2+daMvo10vVlO\nu1/Adx+yptgAxxQmBJGBk/yyjf2Phl8qYpVaeVuYWjyJ1v2i5SopJaviFOxYRPO3\n8r1d8nSxOQKBgQCIYEUvMMk84ol7UV4/ivm4WrY+eL5GzXPS3sE+IUUt6GWeorUc\nfK3pKLNXSwb802fkxpPhsr/XFAlAZcysjLaH+WQS9AMhYr2eCsDxj5VMKS4BnopH\nJgfEH3iEQOhL0oMM5BoqmxVD1oXHDBhZMUNCJFiy1a5szIIfM2mi1FRHswKBgQCa\n3BAuMdmGhX0LVmYlfawLC9OU4NgBrRUx6ToTui460ey+PTj3YkjHyfotQQlob1JI\nmnkvB+UEhb+dJadO487xUBHQY8VjeBF7UE2nkRoNFMzNwZ0yoG8ENblPe8MiZ0eO\nMdBg/KK9OSjWiO843ed+EW2OM3rjsq1mxexYiHGs2QKBgBbTtzyuyVUTl5I6jNtl\nXcd7iUdsCz4+I7nIu9OZOM5W0jwx1xh7y7CtyMeRr+9aopsiMslF+phffrbM7uT9\nqEg5Oygsye8Ux9Rx6us18UnTb1L8p8zfw2flRCCCuHiYuXOft8Me3Fa0pv5UypFw\nl+BEv9kvxIO37y667p4kvJnq\n-----END PRIVATE KEY-----\n	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600235830-tr9ddt/api-1777600235628.techmobile.local.csr.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600235830-tr9ddt/api-1777600235628.techmobile.local.key.pem	pem	1	5
3	api-1777600262376.techmobile.local	RSA_2048	2026-05-01 04:51:02.598718	SIGNED	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=Platform, CN=api-1777600262376.techmobile.local, emailAddress=ops@techmobile.local	-----BEGIN CERTIFICATE REQUEST-----\nMIIDuDCCAqACAQAwgbMxCzAJBgNVBAYTAk1HMRMwEQYDVQQIDApBbmFsYW1hbmdh\nMRUwEwYDVQQHDAxBbnRhbmFuYXJpdm8xEzARBgNVBAoMClRlY2hNb2JpbGUxETAP\nBgNVBAsMCFBsYXRmb3JtMSswKQYDVQQDDCJhcGktMTc3NzYwMDI2MjM3Ni50ZWNo\nbW9iaWxlLmxvY2FsMSMwIQYJKoZIhvcNAQkBFhRvcHNAdGVjaG1vYmlsZS5sb2Nh\nbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKYTYtQdmlSnpRbWfNlb\nje0DPjFKji2G3rCmoji4RKa4JaWRF/XV/YAKHHXE+MsxK8ZXdxsYJ7ZujVmTXzKp\nhBkAzuA99pmhyXqbSTgPzPC9mPyq45HXep5CqRulZCgwVUTKLGk5J2mqKAhn1z5Z\nnw2RSkjjaupelvn7GjYK+lyp26MNkbwcmLZfcENygiLG57j0tMn5a0+DPa4JMvg1\ns4RjwvGpyeV2aACpIraHk5LzhVOABCfmmwc4zxbXQKX56gufCIEN/BGtGu3hafBd\nFUAXQcSIYmjvIgTtfUQYCs5a5vj1t3oo89QNVeZgwPFDshk61Jlr3NkOpC0z0A8k\nXN0CAwEAAaCBvjCBuwYJKoZIhvcNAQkOMYGtMIGqMB0GA1UdDgQWBBQ/EgOy9GqI\nsns0XcR/HKnsooshVjAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUE\nFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwTwYDVR0RBEgwRoIiYXBpLTE3Nzc2MDAy\nNjIzNzYudGVjaG1vYmlsZS5sb2NhbIIgKi4xNzc3NjAwMjYyMzc2LnRlY2htb2Jp\nbGUubG9jYWwwDQYJKoZIhvcNAQELBQADggEBACTCf3UnmA5E9iZhKz7FrWxbnCtd\nveQRZ+cQJnahcwWdZRrviBY86RYQ/xfWbqSzeT5/JZ3EYaWk5k8EeKGL6C1ICa6x\ng7rdXsBoy2JTXYVUoF90acMLPdgMZ9uYFnC98WVKsS0FPcT1zW2WY/GlbwnYnOa/\nz7tqI901RieHDN5ohat5FdVg2ucrxJA2hyx7nLr4qX8CPfQiXeDtnJ55V4iCp3vL\nMtHSd2WyA1Bdfbjj7zCB93U9c0KTxLb2VAnEN0q6Pv0gAnPWwxu9aiH0GRNQU6R5\nlKrPVFZYznSWOwy+pZR1hcYGP2p/9hLVvMuL7dsNjVzmLXsd8w14iX8omig=\n-----END CERTIFICATE REQUEST-----\n	-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCmE2LUHZpUp6UW\n1nzZW43tAz4xSo4tht6wpqI4uESmuCWlkRf11f2AChx1xPjLMSvGV3cbGCe2bo1Z\nk18yqYQZAM7gPfaZocl6m0k4D8zwvZj8quOR13qeQqkbpWQoMFVEyixpOSdpqigI\nZ9c+WZ8NkUpI42rqXpb5+xo2CvpcqdujDZG8HJi2X3BDcoIixue49LTJ+WtPgz2u\nCTL4NbOEY8LxqcnldmgAqSK2h5OS84VTgAQn5psHOM8W10Cl+eoLnwiBDfwRrRrt\n4WnwXRVAF0HEiGJo7yIE7X1EGArOWub49bd6KPPUDVXmYMDxQ7IZOtSZa9zZDqQt\nM9APJFzdAgMBAAECggEACOvwWot0klOnOhYvrXrjoaCTo2Y+mRIuaGMAl/dziK6f\n0ch89wdAj7OmBRWdypyg82NuJ0B28a/4BqCKHq3zRhHrCyozqIaDzQMGk0JrX2DF\naogWTZa7zutZ1lMI5w0hp4kM4GI3oc+ISFtRDtfAWaQ9JLPtjHBPFVgjTP/t+d2i\njD0tCCbNy1A35moPMjL4OCUvXVMyT8Io/PGh2rGl7vQ3vuvZJAl2oC31W3/NxEy0\nQeaINhOPI8B3tmO1qtFBjbIRBeZkHxfFpplmzgX9uLnZ0jUE5Q5NxSrROnodXVav\nre9ErfVBydrtRU2p5MfRBmVnTYnFHQYpUNfYY5Q8wQKBgQDheIin3SfHPqOGz1ts\nB9UCnsgSSfkqL3b3uRRtMSAwYyTXrSBNv0Hach5qjuCZ1KkJWK7HPKKCgMFoMt95\nXdNcNgxR96mDNhFWLncxqbSEOUEUROWmpdCrNWgRI+V+3YVhyvqqasCv8NYPlGlZ\niSadARWofkdd9epuvuZNrlOGKQKBgQC8kAwd4r/WmPzH9ZJW/tEkt9xMOYZpuhG+\nxl/Yg5f2jhxzTfiJx30GPRvXOABFy0vyUDj3v5sqqCMX3H8FfHxUOXXqKmw6Bb3X\nYkPe1OzWuyYTBtJad1AXcvA75TOsUFPSgGrW+BhY5MN7PSahD3kBo96QrEwyxW4c\nAUskLu/vlQKBgQDExlkdh1lr/jLhOJ7lDYDNpJ2fuIeIVZxSXmiBU1pwYFaLFEEZ\nGU3zw5zgConiN0K/MXJ312dM1en1clCur0ADPfhKoQaDyPAgcrT71swAiadOdUKn\nyhbvFNEaBGYJ7nK2Alv51ukLo/ht6Gx5A8V7SLMKNgs66aALvvdn3Dhw4QKBgBHa\nXZtSxbEOyRgxkwpzk9+zHMOGysgl2tpCM/7u7qtkZyMvpbF91sOJc6Jb5gK1rdoi\naFJkrM9MHg57TPd7AtaCnjxuidKwinnjDuQBKu9lxsQUaEQyeb3Onxo8qDjPXjBX\nAkaaNMvt1OhNMOQc7+sM1dzCw3AnKzaxlKi3XPZFAoGAYQgham06LbpMAn1BVsW7\nXu3A3senmuXH6i0UKXz/JHuSLNQ1QikBZtznhGfIrNx689MGUTsFCjdEwCAm5/bv\nm15D6ca/QnW03AQHP9JDgziB4xDsAvi9GCk/PD+2L1EyhZvfNYAoIrd+YqBWNoYM\nKnsvP08dXsIrHJTkOeuU1Ww=\n-----END PRIVATE KEY-----\n	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600262527-2i5h3q/api-1777600262376.techmobile.local.csr.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600262527-2i5h3q/api-1777600262376.techmobile.local.key.pem	pem	2	6
4	api.balancer 	RSA_2048	2026-05-01 13:17:58.380626	IMPORTED	CN=projet.local	-----BEGIN CERTIFICATE REQUEST-----\nMIIClzCCAX8CAQAwFzEVMBMGA1UEAwwMcHJvamV0LmxvY2FsMIIBIjANBgkqhkiG\n9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1AGNX/ouwK78EeijDnYNIsPjlJ9QR6QDiYQJ\nIrufJynUVVaSG5ksy0/jPQirVnC1P06pWuohlqk0wXHnjtspsdaUUo3hvIUxozvq\nlCASj7ZZdLOw+1GVMmJYBLrw6Ous0U/mKdDe/ER4Hy5cMxXnYijZtTJep5Yz7Mt6\n+MnVszF5QI8PSVZcAKbseS7yZOOl8Z0ldPP0WcW3r37EWvAyGsbYZc5IrAEXlBNp\n41cwrA0KE8sf3SldtYVZ+6tR6o4JGOQ9g4GJqpvab/BdJjPdROzaH356/Yl5nKDd\nu9ItIqHiPjk6FVdwzay3moxaQ2ya5ZImVnAS8U5MelutgBdTJQIDAQABoDswOQYJ\nKoZIhvcNAQkOMSwwKjAoBgNVHREEITAfggxwcm9qZXQubG9jYWyCCWxvY2FsaG9z\ndIcEwKg4FzANBgkqhkiG9w0BAQsFAAOCAQEAxicnCODgnWt+D3bc1RJUCH9Uiopo\nl8NyTUm6mqECt+R7s8pm3ejLedVEPmQ+9rsIlfflRWm4WFVOtSKsLWogJNltFDXC\newOf/Chxw8u3UzfpCgxsl4Mj3hb64vIEakkrGX4Umgx7AuFmezs21ZdyJRMtKmtI\nVd7aCmT76R9hdD2ZO++rsf/mln+2m6S9cptOLZznES7PG1IKSD3t+uy0O98rGFXC\n072HezrUXUexFwCpYhrhvDRrqhoqfubOUmu3/ybCHFhFedr6w5FmkBB3GsgqHOz7\nRKxPt+JPSToe/BXSpVl+ru3RE4rPADpPGNNUv6KgBTOIvpvNMKGbcK62Aw==\n-----END CERTIFICATE REQUEST-----\n	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/imported-csr-1777630678328-k1qh5q/api.balancer.csr.pem	\N	pem	\N	\N
5	generatedcsr	RSA_2048	2026-05-01 13:19:08.928523	SIGNED	C=MG, ST=Fianarantsoa , L=Fianarantsoa , O=Claudine , OU=Dev, CN=generatedcsr, emailAddress=hanitraclaudine@gmail.com	-----BEGIN CERTIFICATE REQUEST-----\nMIIDfjCCAmYCAQAwgaAxCzAJBgNVBAYTAk1HMRYwFAYDVQQIDA1GaWFuYXJhbnRz\nb2EgMRYwFAYDVQQHDA1GaWFuYXJhbnRzb2EgMRIwEAYDVQQKDAlDbGF1ZGluZSAx\nDDAKBgNVBAsMA0RldjEVMBMGA1UEAwwMZ2VuZXJhdGVkY3NyMSgwJgYJKoZIhvcN\nAQkBFhloYW5pdHJhY2xhdWRpbmVAZ21haWwuY29tMIIBIjANBgkqhkiG9w0BAQEF\nAAOCAQ8AMIIBCgKCAQEA0rmdaTYfVZUL1sEcPN4kWaoCAJTxk5omhXIK3OmSpgBM\n7Wi5XVXF19fxXNPaK28mXnSkF5G8wWxNKNCMB5Qnv7YglFTEhT22pW4fvHZYbgHI\nRtHN49JtpKKAqwB96DjndR1haqnKL1gfL6hufCvR72x+hrazW6tddAsBmby1x7Fr\n9j4ek1zWW9O9cI+gNY64qcsJWWYHgaNGRRpLb9+qsqRMZAQlpyinu2Qkm5qtELGC\n0OHwI70xJ7cn0TDWYKoLBp2El2SMt/BMzlLTywutDUPh8ZW50UTbSTx0vhehMt9h\nbYUzPdA4LIzHMknHY9c7zAmlLmfASfozsOyr8u8gUQIDAQABoIGXMIGUBgkqhkiG\n9w0BCQ4xgYYwgYMwHQYDVR0OBBYEFDusUmgQC+PYvm3cLANi9ycjhlomMAkGA1Ud\nEwQCMAAwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEF\nBQcDAjAoBgNVHREEITAfggxnZW5lcmF0ZWRjc3KCD2V4ZW1wbGUuZG9tYWluZTAN\nBgkqhkiG9w0BAQsFAAOCAQEAvzRodCW8/VqbwHqRllhQgX4tBwZ+Qvvt5mjy7XvY\nMfxsg/7fiUSLGw5M5yqYNX0A02Pg2RkiuswmJdpGnJ0byKv9M431DFMahTRusUhp\n8bQ32XbUbTjezpBbuRvdKocgj856ATEaVordihnRIO8gYBXeBGh3OrGxmS8FkkRa\nD9ubLUAsqEDqJ2dMrfTHdUOtHrhavcHVIAMhHCbRMb0COLsDjXU4OLZhwip7wjk0\nHeHJSj12jJHfW+0nFa2acUrncICjQmMHoU/XbmCeO2f32LlTwn/gec7tFM5mEh8+\nZItHdKI5uL1WuLabgWNV2W2CoKr+icjXJMRc9Hz3LEIg2A==\n-----END CERTIFICATE REQUEST-----\n	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDSuZ1pNh9VlQvW\nwRw83iRZqgIAlPGTmiaFcgrc6ZKmAEztaLldVcXX1/Fc09orbyZedKQXkbzBbE0o\n0IwHlCe/tiCUVMSFPbalbh+8dlhuAchG0c3j0m2kooCrAH3oOOd1HWFqqcovWB8v\nqG58K9HvbH6GtrNbq110CwGZvLXHsWv2Ph6TXNZb071wj6A1jripywlZZgeBo0ZF\nGktv36qypExkBCWnKKe7ZCSbmq0QsYLQ4fAjvTEntyfRMNZgqgsGnYSXZIy38EzO\nUtPLC60NQ+HxlbnRRNtJPHS+F6Ey32FthTM90DgsjMcyScdj1zvMCaUuZ8BJ+jOw\n7Kvy7yBRAgMBAAECggEAQuTalA4y10O33OYztRzd1Dr0ZMPjhnQ+e0lPKn7ZZ2oc\nAZenlHoIkrMB83JrRTOFLiH//11r2skrG2RMt5EwJxtFb2ETe6qyIwT4/SZifxWA\nwv6SShrAZK2Tg/VlgsUhsNtxU99viCUEzWe+Hxv4CnXaGqDAAj89rPtbeDbgS/Iy\naJU+DEw2RJD9YITglIAkSipRto6ZemKVD+lQQ1alQ3Npg2eXRBwTgnSvQ49xfJpm\nGMbSwA2uz/NIKWBphmkGx29xlAA2zL9ecOIZgkIOzTDXtu/tokAhnxqnIINF9ytc\nTYg3zGdE9Gt3vPVUeQunXs45pFVlTV4V10kWGrInQwKBgQD39lazKBJMdk7cdsr1\nqosVExZdPRVErsyjhEL1HYveZ/wSAEAyy1ZG158X0ZkdWBpB4CFybcyWfDxJAm88\na6kugK1KDt9wmlEF6yf9MvVDPxfitX3SqnStJ8P5QFY4tTwDpHegP9LnY7I8CsAA\n1j1j2NVafXjDiSdAWcQEd/JUBwKBgQDZjkV1jUMcnLaSyIIQYYZrYbZ5+z99kJ4/\npHrGz/NU25oiE8Tmc+bPPBSeI6VMNxA3P4FN7PZuqMWN6ZSPXumBD3ToT88CmHYS\nOZKgWV/IBAkNSJyqzKUTxtDsBMk1tvtSsymApmbHDuapfk/6ztc1s9nDqULJ/3VA\nVz1b2ajC5wKBgQDBY22hEsqaudatmTSXvyf0CsvxchdpVs8hZKD4HNAeaIku3OU0\n+GNUowxgfkblnPX1lMFhRoM+hqxZ4L0yqWDsdM0yKkFXx/MTI6Evl5Ozm7ycQyJb\nsDeJaK8ucWANoEOrL5Vg9QYfEyFKNLQksvJ0MgPMLHmIPyrOxHPdbFMh9wKBgH7f\n5cokU9s/2YnIvXFoLsg49/4zdFd6G4/qEGAZrkLyvvTYqp/rP9PjqfJ/v0qvYhmW\nQ4Z6h00JyAx3CFiEdZD6vqcsxAEzgMgoI0a4WI+BKvZAPn2tUygxbm32bJGS4Qbd\nzXplkNLN8d8u9t3B+ugqtvjQoU7EWFDpj7MdQLpJAoGBANbobuSFgdAo9l8QqaMI\nzPqdlJdtM9kC238/qowO46zln5BBWp9oNVxVWaVNR6WP0KMlKUcHPNSl1CTpnDxo\nOH3XnfpUXWJCoENoq0MwmYQ7aVEYwQhvCEOvXAtSc/ijK7I0Ja+uuaJP4bBqPEAX\niE6b9RO6lLGoyq5b5UMu7N/a\n-----END PRIVATE KEY-----\n	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777630748792-oeq8y8/generatedcsr.csr.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777630748792-oeq8y8/generatedcsr.key.pem	pem	3	12
\.


--
-- Data for Name: certificates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.certificates (cert_id, common_name, cert_type, algorithm, issued_at, expires_at, status, ca_id, subject_dn, issuer_dn, serial_number, fingerprint_sha256, key_path, cert_path, source_format, csr_id) FROM stdin;
2	api-1777600262376.techmobile.local	SERVER	RSA_2048	2026-05-01 04:51:02.691715	2027-05-01 01:51:02.691	VALID	6	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=Platform, CN=api-1777600262376.techmobile.local, emailAddress=ops@techmobile.local	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=PKI, CN=Test Root 1777600262376, emailAddress=pki@techmobile.local	03768871395D7EB6A4C504B13AB53FED04F08255	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600262527-2i5h3q/api-1777600262376.techmobile.local.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/certificates/signed-from-csr-1777600262622-mkbbbn/api-1777600262376.techmobile.local.crt.pem	pem	3
1	api-1777600235628.techmobile.local	SERVER	RSA_2048	2026-05-01 04:50:36.091558	2027-05-01 01:50:36.091	REVOKED	5	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=Platform, CN=api-1777600235628.techmobile.local, emailAddress=ops@techmobile.local	C=MG, ST=Analamanga, L=Antananarivo, O=TechMobile, OU=PKI, CN=Test Root 1777600235628, emailAddress=pki@techmobile.local	42D41901125806F4B2259E9A479920208CC98ADA	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777600235830-tr9ddt/api-1777600235628.techmobile.local.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/certificates/signed-from-csr-1777600236019-f4tkju/api-1777600235628.techmobile.local.crt.pem	pem	2
3	generatedcsr	SERVER	RSA_2048	2026-05-01 13:21:05.728367	2027-05-01 10:21:05	VALID	12	C=MG, ST=Fianarantsoa , L=Fianarantsoa , O=Claudine , OU=Dev, CN=generatedcsr, emailAddress=hanitraclaudine@gmail.com	C=MG, ST=FIANARANTSOA, L=Tanambao, O=ENI, OU=L3, CN=MyRootCA, emailAddress=hanitraclaudine@gmail.com	75C8CBD94CAB411B15348EDECD1315F5B2BA65A7	\N	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/csrs/generated-csr-1777630748792-oeq8y8/generatedcsr.key.pem	/home/claudine/Documents/DEVOPS/Projects/TechMobile/backend/storage/certificates/signed-from-csr-1777630865658-wmeqws/generatedcsr.crt.pem	pem	5
\.


--
-- Data for Name: csr_sans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.csr_sans (csr_san_id, csr_id, domain) FROM stdin;
1	1	api-1777600163380.techmobile.local
2	1	*.1777600163380.techmobile.local
3	2	api-1777600235628.techmobile.local
4	2	*.1777600235628.techmobile.local
5	3	api-1777600262376.techmobile.local
6	3	*.1777600262376.techmobile.local
7	4	api.balancer 
8	4	projet.local
9	4	localhost
10	5	generatedcsr
11	5	exemple.domaine
\.


--
-- Name: certificate_authorities_ca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.certificate_authorities_ca_id_seq', 13, true);


--
-- Name: certificate_sans_san_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.certificate_sans_san_id_seq', 6, true);


--
-- Name: certificate_signing_requests_csr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.certificate_signing_requests_csr_id_seq', 5, true);


--
-- Name: certificates_cert_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.certificates_cert_id_seq', 3, true);


--
-- Name: csr_sans_csr_san_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.csr_sans_csr_san_id_seq', 11, true);


--
-- Name: certificate_authorities certificate_authorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_authorities
    ADD CONSTRAINT certificate_authorities_pkey PRIMARY KEY (ca_id);


--
-- Name: certificate_sans certificate_sans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_sans
    ADD CONSTRAINT certificate_sans_pkey PRIMARY KEY (san_id);


--
-- Name: certificate_signing_requests certificate_signing_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_signing_requests
    ADD CONSTRAINT certificate_signing_requests_pkey PRIMARY KEY (csr_id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (cert_id);


--
-- Name: csr_sans csr_sans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csr_sans
    ADD CONSTRAINT csr_sans_pkey PRIMARY KEY (csr_san_id);


--
-- Name: certificate_authorities certificate_authorities_parent_ca_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_authorities
    ADD CONSTRAINT certificate_authorities_parent_ca_id_fkey FOREIGN KEY (parent_ca_id) REFERENCES public.certificate_authorities(ca_id);


--
-- Name: certificate_sans certificate_sans_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_sans
    ADD CONSTRAINT certificate_sans_certificate_id_fkey FOREIGN KEY (certificate_id) REFERENCES public.certificates(cert_id) ON DELETE CASCADE;


--
-- Name: certificate_signing_requests certificate_signing_requests_ca_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_signing_requests
    ADD CONSTRAINT certificate_signing_requests_ca_id_fkey FOREIGN KEY (ca_id) REFERENCES public.certificate_authorities(ca_id);


--
-- Name: certificate_signing_requests certificate_signing_requests_signed_certificate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_signing_requests
    ADD CONSTRAINT certificate_signing_requests_signed_certificate_id_fkey FOREIGN KEY (signed_certificate_id) REFERENCES public.certificates(cert_id);


--
-- Name: certificates certificates_ca_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_ca_id_fkey FOREIGN KEY (ca_id) REFERENCES public.certificate_authorities(ca_id);


--
-- Name: certificates certificates_csr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_csr_id_fkey FOREIGN KEY (csr_id) REFERENCES public.certificate_signing_requests(csr_id);


--
-- Name: csr_sans csr_sans_csr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.csr_sans
    ADD CONSTRAINT csr_sans_csr_id_fkey FOREIGN KEY (csr_id) REFERENCES public.certificate_signing_requests(csr_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict dcKfmQPiLVxbfbbKgf70XKcgunMCPJsa7eeB6WaXgtPqwzSfGnc2hXRXmKS2hnb

