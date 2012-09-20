%PNMREAD - Reads the binary netpbm formats PBM, PGM, and PPM.
%
% imread() should be able to read netpbm files by itself, however, some versions
% of GNU Octave's imread may be faulty.
%
% Syntax:  I = pnmread(fname)
%
% Inputs:
%    fname - an image's filename
%
% Outputs:
%    I - a matrix representing the contents of the image pointed to by fname.
%
% Example:
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: PNMWRITE, BAYER_DEMOSAIC, MYIMREAD
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function I = pnmread(fname)

	if (nargin ~= 1 || isempty(fname))
		usage('pnmread(fname)');
	end

	fid = fopen(fname, 'r');

	if (fid == -1)
		error(['pnmread: cannot find ' fname '.'])
	else
		magicnum = fgetl(fid);
		if strcmp(magicnum, 'P4') %binary PBM

			hline2 = fgetl(fid); %second line of header

			if (hline2(1) == '#')
				imgsize = sscanf(fgetl(fid),'%d %d');
			else %no comment in header
				imgsize = sscanf(hline2,'%d %d');
			end

			w = imgsize(1);
			h = imgsize(2);
			%must read bits in blocks of 8
			[A, count] = fread(fid, Inf, 'uint8');

			if (count ~= w*h)
				fclose(fid);
				error('pnmread: image data has invalid size.');
			end

			B = dec2bin(A); %convert numbers to equivalent binary string
			C = uint8(B)-uint8('0'); %binary string -> binary int string
			I = reshape(C.', [w, h]);
			I = I.'; %transpose so I has the same orientation as source image

		elseif strcmp(magicnum, 'P5') %binary PGM

			hline2 = fgetl(fid); %second line of header

			if (hline2(1) == '#')
				imgsize = sscanf(fgetl(fid),'%d %d');
			else %no comment in header
				imgsize = sscanf(hline2,'%d %d');
			end

			w = imgsize(1);
			h = imgsize(2);
			maxcolor = sscanf(fgetl(fid),'%d');
			if (maxcolor ~= ((2^8)-1) && maxcolor ~= ((2^16)-1))
				fclose(fid);
				error('pnmread: only 8 and 16 bit images supported.')
			end

			bpp = log2(maxcolor+1);
			prec = ['uint' num2str(bpp)];

			% must be big-endian for 16 bpp PGMs
			[I, count] = fread(fid, [w, h], prec, 0, 'ieee-be');

			if (count ~= w*h)
				fclose(fid);
				error('pnmread: image data has invalid size.');
			end

			I = I.'; %transpose so I has the same orientation as source image

		elseif strcmp(magicnum, 'P6') %binary PPM

			hline2 = fgetl(fid);

			if (hline2(1) == '#')
				imgsize = sscanf(fgetl(fid),'%d %d');
			else
				imgsize = sscanf(hline2,'%d %d');
			end

			w = imgsize(1);
			h = imgsize(2);
			maxcolor = sscanf(fgetl(fid),'%d');
			if (maxcolor ~= ((2^8)-1) && maxcolor ~= ((2^16)-1))
				fclose(fid);
				error('pnmread: only 8 and 16 bit images supported.')
			end

			bpp = log2(maxcolor+1);
			prec = ['uint' num2str(bpp)];
			%RGB triplet, 3 numbers per pixel
			[A, count] = fread(fid, [3*w, h], prec, 0, 'ieee-be');

			if (count ~= 3*w*h)
				fclose(fid);
				error('pnmread: image data has invalid size.');
			end

			I = zeros(h, w, 3);
			I(:,:,1) = reshape(A(1:3:end), [w, h]).'; %Red
			I(:,:,2) = reshape(A(2:3:end), [w, h]).'; %Green
			I(:,:,3) = reshape(A(3:3:end), [w, h]).'; %Blue

		else %magic number is invalid
			fclose(fid);
			error('pnmread: not a PNM image.')
		end

		fclose(fid);

		if (strcmpi(prec, 'uint8') == 1)
			I = uint8(I);
		elseif (strcmpi(prec, 'uint16') == 1)
			I = uint16(I);
		end

	end
end
